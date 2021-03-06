import ProjectUtils._

enablePlugins(BenchExec)

benchmarks ++= Seq(
  suiteGen("004endive-apalache", endiveSpecs)
)

lazy val endiveSpecs = Seq(
  Spec("endive-specs","MC3_Consensus.tla", inv = "Inv"),
  Spec("endive-specs","MC3_Simple.tla", inv = "Inv"),
  Spec("endive-specs","MC3_SimpleRegular.tla", inv = "Inv"),
  Spec("endive-specs","MC3_TwoPhase.tla", inv = "TCConsistent"),
  Spec("endive-specs","MC3_client_server_ae.tla", inv = "Safety"),
  Spec("endive-specs","MC3_consensus_epr.tla", inv = "Safety"),
  Spec("endive-specs","MC3_consensus_forall.tla", inv = "Safety"),
  Spec("endive-specs","MC3_consensus_wo_decide.tla", inv = "Safety"),
  Spec("endive-specs","MC3_learning_switch.tla", inv = "Safety"),
  Spec("endive-specs","MC3_lockserv.tla", inv = "Mutex"),
  Spec("endive-specs","MC3_lockserv_automaton.tla", inv = "Mutex"),
  Spec("endive-specs","MC3_lockserver.tla", inv = "Inv"),
  Spec("endive-specs","MC3_majorityset_leader_election.tla", inv = "Safety"),
  Spec("endive-specs","MC3_naive_consensus.tla", inv = "Safety"),
  Spec("endive-specs","MC3_quorum_leader_election.tla", inv = "Safety"),
  Spec("endive-specs","MC3_sharded_kv.tla", inv = "Safety"),
  Spec("endive-specs","MC3_sharded_kv_no_lost_keys.tla", inv = "Safety"),
  Spec("endive-specs","MC3_simple_decentralized_lock.tla", inv = "Inv"),
  Spec("endive-specs","MC3_toy_consensus.tla", inv = "Inv"),
  Spec("endive-specs","MC3_toy_consensus_epr.tla", inv = "Safety"),
  Spec("endive-specs","MC3_toy_consensus_forall.tla", inv = "Inv"),
  Spec("endive-specs","MC3_two_phase_commit.tla", inv = "Safety"),
  Spec("endive-specs","MC3_MongoLoglessDynamicRaft.tla", inv = "Safety")
)