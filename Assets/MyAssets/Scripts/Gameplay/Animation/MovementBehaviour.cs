using Unity.Mathematics;
using UnityEngine;

public class MovementBehaviour : StateMachineBehaviour {
  [SerializeField] private float m_rotate_speed = 180f;
  [SerializeField] private float m_f_speed = 0.0f;
  [SerializeField] private float m_b_speed = 0.0f;
  [SerializeField] private float m_lr_speed = 0.0f;
  override public void OnStateUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
    float velocity_lr = animator.GetFloat("velocity_lr");
    float velocity_fb = animator.GetFloat("velocity_fb");
    float target_rotate = math.atan2(velocity_lr, velocity_fb) / math.PI * 180;
    float max_ratate = m_rotate_speed * Time.deltaTime;
    if (math.abs(target_rotate) > max_ratate) {
      target_rotate = target_rotate > 0 ? max_ratate : -max_ratate;
    }
    animator.transform.rotation = Quaternion.Euler(0.0f, target_rotate, 0.0f) * animator.transform.rotation;
    if (m_f_speed != 0.0 || m_b_speed != 0.0 || m_lr_speed != 0.0f) {
      Vector3 modle_front = animator.transform.forward;
      modle_front.y = 0.0f;
      modle_front.Normalize();
      Vector3 modle_right = Vector3.Cross(Vector3.up, modle_front);
      animator.transform.position += ((velocity_fb >= 0.0 ? m_f_speed : m_b_speed) * velocity_fb * modle_front + m_lr_speed * velocity_lr * modle_right) * Time.deltaTime;
    }
  }
}
