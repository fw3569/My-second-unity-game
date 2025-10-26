using UnityEngine;

public class StaggerBehaviour : StateMachineBehaviour {
  override public void OnStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
    animator.SetBool("InStagger", false);
  }
}
