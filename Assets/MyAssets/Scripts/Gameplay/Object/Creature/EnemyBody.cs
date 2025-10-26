using UnityEngine;

[RequireComponent(typeof(EnemyAI))]
public class EnemyBody : CreatureBody {
  private EnemyAI m_ai;
  protected override void Awake() {
    base.Awake();
    m_ai = GetComponent<EnemyAI>();
  }
  protected override void ResetTriggers() {
    m_animator.ResetTrigger("Walk");
    m_animator.ResetTrigger("Run");
    m_animator.ResetTrigger("Attack");
  }
  public void Walk() {
    ResetTriggers();
    m_animator.SetTrigger("Walk");
    m_animator.SetFloat("velocity_fb", 0.0f);
    m_animator.SetFloat("velocity_lr", 0.0f);
  }
  public void Run() {
    ResetTriggers();
    m_animator.SetTrigger("Run");
    m_animator.SetFloat("velocity_fb", 0.0f);
    m_animator.SetFloat("velocity_lr", 0.0f);
  }
  public void UpdateMoveVector(float velocity_fb, float velocity_lr) {
    m_animator.SetFloat("velocity_fb", velocity_fb);
    m_animator.SetFloat("velocity_lr", velocity_lr);
  }
  public void MoveTo(Vector3 pos) {
    Vector3 modle_front = transform.forward;
    modle_front.y = 0.0f;
    modle_front.Normalize();
    Vector3 modle_right = Vector3.Cross(Vector3.up, modle_front);
    Vector3 move_vector = Vector3.Normalize(pos - transform.position);
    float velocity_fb = Vector3.Dot(move_vector, modle_front);
    float velocity_lr = Vector3.Dot(move_vector, modle_right);
    UpdateMoveVector(velocity_fb, velocity_lr);
  }
  public void Attack() {
    ResetTriggers();
    m_animator.SetTrigger("Attack");
  }
  protected override void Stagger(AttackBox atkbox) {
    base.Stagger(atkbox);
    if (m_ai != null) {
      m_ai.TransferState("Idle");
    }
  }
  protected override void Dead() {
    base.Dead();
    if (m_ai != null) {
      m_ai.TransferState("Idle");
    }
  }
}
