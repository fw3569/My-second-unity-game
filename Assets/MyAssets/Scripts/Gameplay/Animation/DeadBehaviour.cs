using UnityEngine;
using UnityEngine.SceneManagement;

public class DeadBehaviour : StateMachineBehaviour {
  override public void OnStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
    if (animator.TryGetComponent<PlayerController>(out var _)) {
      SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    } else {
      Destroy(animator.gameObject);
    }
  }
}
