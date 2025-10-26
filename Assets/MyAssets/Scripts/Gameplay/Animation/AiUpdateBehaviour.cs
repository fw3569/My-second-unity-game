using UnityEngine;

public class AiUpdateBehaviour : StateMachineBehaviour {
  [SerializeField] private bool m_is_update_in_enter = false;
  [SerializeField] private bool m_is_update_each_frame = false;
  [SerializeField] private bool m_is_update_in_exit = false;
  override public void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
    if (m_is_update_in_enter && animator.TryGetComponent(out FSM ai)) {
      ai.UpdateFSM();
    }
  }
  override public void OnStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
    if (m_is_update_in_exit && animator.TryGetComponent(out FSM ai)) {
      ai.UpdateFSM();
    }
  }
  override public void OnStateUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
    if (m_is_update_each_frame && animator.TryGetComponent(out FSM ai)) {
      ai.UpdateFSM();
    }
  }
}
