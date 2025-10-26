using UnityEngine;

public class VisibleArea : MonoBehaviour {
  void OnTriggerEnter(Collider col) {
    if (col.CompareTag("Player")) {
      transform.parent.GetComponent<EnemyAI>().FindTarget(col.gameObject);
    }
  }
  void OnTriggerExit(Collider col) {
    if (col.CompareTag("Player")) {
      transform.parent.GetComponent<EnemyAI>().LostTarget(col.gameObject);
    }
  }
}
