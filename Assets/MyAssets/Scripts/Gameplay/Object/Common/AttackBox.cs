using UnityEngine;

public class AttackBox : MonoBehaviour {
  static private uint s_seq = 0;
  public AttackBox() {
    UpdateSeq();
  }
  public void UpdateSeq() {
    seq = ++s_seq;
  }
  public uint seq;
  public int atk = 0;
}
