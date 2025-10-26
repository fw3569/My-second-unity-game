using UnityEngine;

public class JumpBehaviour : StateMachineBehaviour {
  [SerializeField] private float m_jump_velocity = 5.0f;
  Vector3 m_move_velocity = new(0.0f, 0.0f, 0.0f);
  override public void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
    Rigidbody rigidbody = animator.GetComponent<Rigidbody>();
    m_move_velocity = rigidbody.linearVelocity;
    rigidbody.AddForce(new Vector3(0.0f, m_jump_velocity, 0.0f), ForceMode.VelocityChange);
  }
  override public void OnStateUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
    animator.transform.position += new Vector3(m_move_velocity.x, 0.0f, m_move_velocity.z) * Time.deltaTime;
  }
}
