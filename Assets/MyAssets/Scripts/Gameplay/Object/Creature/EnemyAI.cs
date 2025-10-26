using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(EnemyBody))]
public class EnemyAI : FSM {
  private EnemyBody m_body;
  [SerializeField] private List<GameObject> m_patrol_points;
  int m_next_patrol_points_index = 0;
  [SerializeField] private float m_patrol_target_distance = 0.3f;
  [SerializeField] private GameObject m_attack_target;
  [SerializeField] private List<GameObject> m_attack_targets;
  [SerializeField] private float m_attack_distance = 1.0f;
  [SerializeField] private float m_attack_distance_running = 2f;
  public bool attack_finish = false;
  protected virtual void Awake() {
    m_body = GetComponent<EnemyBody>();
  }
  protected override void ConstructStates() {
    m_states = new() {
      ["Idle"] = new EnemyIdleState(),
      ["Patrol"] = new EnemyPatrolState(),
      ["Chase"] = new EnemyChaseState(),
      ["Attack"] = new EnemyAttackState()
    };
  }
  protected override void EnterInitState() {
    TransferState("Idle");
  }
  internal virtual bool Attackable(float distance) {
    if (!m_attack_target) {
      return false;
    }
    Vector3 target_vector = m_attack_target.transform.position - transform.position;
    if (target_vector.magnitude < distance && Vector3.Dot(target_vector, transform.forward) > 0.0f) {
      return true;
    } else {
      return false;
    }
  }
  public void FindTarget(GameObject target) {
    if (target == null) {
      return;
    }
    m_attack_targets.Add(target);
    if (m_attack_target == null) {
      m_attack_target = target;
    }
  }
  public void LostTarget(GameObject target) {
    m_attack_targets.Remove(target);
    if (m_attack_target == target) {
      if (m_attack_targets.Count != 0) {
        m_attack_target = m_attack_targets[0];
      } else {
        m_attack_target = null;
      }
    }
  }
  public class EnemyIdleState : IFSMState {
    public void TransferState(FSM fsm) {
      EnemyAI ai = (EnemyAI)fsm;
      if (ai.m_attack_target == null) {
        if (ai.m_patrol_points.Count != 0) {
          ai.TransferState("Patrol");
        }
        return;
      }
      if (ai.Attackable(ai.m_attack_distance)) {
        ai.TransferState("Attack");
        return;
      } else {
        ai.TransferState("Chase");
        return;
      }
    }
  }
  public class EnemyPatrolState : IFSMState {
    public void OnEnterState(FSM fsm) {
      EnemyAI ai = (EnemyAI)fsm;
      ai.m_body.Walk();
    }
    public void TransferState(FSM fsm) {
      EnemyAI ai = (EnemyAI)fsm;
      if (ai.m_attack_target != null) {
        ai.TransferState("Chase");
        return;
      }
    }
    public void UpdateState(FSM fsm) {
      EnemyAI ai = (EnemyAI)fsm;
      if (ai.m_patrol_points == null || ai.m_patrol_points.Count == 0) {
        return;
      }
      if (Vector3.Distance(ai.m_patrol_points[ai.m_next_patrol_points_index].transform.position, ai.transform.position) < ai.m_patrol_target_distance) {
        ai.m_next_patrol_points_index = (ai.m_next_patrol_points_index + 1) % ai.m_patrol_points.Count;
      }
      ai.m_body.MoveTo(ai.m_patrol_points[ai.m_next_patrol_points_index].transform.position);
    }
  }
  public class EnemyChaseState : IFSMState {
    public void OnEnterState(FSM fsm) {
      EnemyAI ai = (EnemyAI)fsm;
      ai.m_body.Run();
    }
    public void TransferState(FSM fsm) {
      EnemyAI ai = (EnemyAI)fsm;
      if (ai.m_attack_target == null) {
        ai.TransferState("Patrol");
        return;
      }
      if (ai.Attackable(ai.m_attack_distance_running)) {
        ai.TransferState("Attack");
        return;
      }
    }
    public void UpdateState(FSM fsm) {
      EnemyAI ai = (EnemyAI)fsm;
      if (ai.m_attack_target != null) {
        ai.m_body.MoveTo(ai.m_attack_target.transform.position);
      }
    }
  }
  public class EnemyAttackState : IFSMState {
    public void OnEnterState(FSM fsm) {
      EnemyAI ai = (EnemyAI)fsm;
      ai.m_body.Attack();
    }
    public void OnExitState(FSM fsm) {
      EnemyAI ai = (EnemyAI)fsm;
      ai.attack_finish = false;
      ai.m_body.weapon.GetComponent<Collider>().enabled = false;
    }
    public void TransferState(FSM fsm) {
      EnemyAI ai = (EnemyAI)fsm;
      if (!ai.attack_finish) {
        return;
      }
      ai.TransferState("Idle");
    }
  }
}
