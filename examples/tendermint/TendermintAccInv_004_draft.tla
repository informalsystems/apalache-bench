------------------- MODULE TendermintAccInv_004_draft --------------------------
(*
 An inductive invariant for TendermintAcc3, which capture the forked
 and non-forked cases.

 * Version 4. Fix the inductive invariant,
 *            as violations were found by Apalache v0.27.
 * Version 3. Modular and parameterized definitions.
 * Version 2. Bugfixes in the spec and an inductive invariant.

 Igor Konnov, Josef Widder, 2020-2022.
 *)

EXTENDS TendermintAcc_004_draft

(************************** TYPE INVARIANT ***********************************)
(* first, we define the sets of all potential messages *)
\* @type: Set($proposeMsg);
AllProposals ==
  [type: {"PROPOSAL"},
   src: AllProcs,
   round: Rounds,
   proposal: ValuesOrNil,
   validRound: RoundsOrNil]

\* @type: Set($preMsg);
AllPrevotes ==
  [type: {"PREVOTE"},
   src: AllProcs,
   round: Rounds,
   id: ValuesOrNil]

\* @type: Set($preMsg);
AllPrecommits ==
  [type: {"PRECOMMIT"},
   src: AllProcs,
   round: Rounds,
   id: ValuesOrNil]

(* the standard type invariant -- importantly, it is inductive *)
TypeOK ==
    /\ round \in [Corr -> Rounds]
    /\ step \in [Corr -> { "PROPOSE", "PREVOTE", "PRECOMMIT", "DECIDED" }]
    /\ decision \in [Corr -> ValidValues \union {NilValue}]
    /\ lockedValue \in [Corr -> ValidValues \union {NilValue}]
    /\ lockedRound \in [Corr -> RoundsOrNil]
    /\ validValue \in [Corr -> ValidValues \union {NilValue}]
    /\ validRound \in [Corr -> RoundsOrNil]
    /\ msgsPropose \in [Rounds -> SUBSET AllProposals]
    /\ BenignRoundsInMessages(msgsPropose)
    /\ msgsPrevote \in [Rounds -> SUBSET AllPrevotes]
    /\ BenignRoundsInMessages(msgsPrevote)
    /\ msgsPrecommit \in [Rounds -> SUBSET AllPrecommits]
    /\ BenignRoundsInMessages(msgsPrecommit)
    /\ evidencePropose \in SUBSET AllProposals
    /\ evidencePrevote \in SUBSET AllPrevotes
    /\ evidencePrecommit \in SUBSET AllPrecommits
    /\ action \in {
        "Init",
        "InsertProposal",
        "UponProposalInPropose",
        "UponProposalInProposeAndPrevote",
        "UponQuorumOfPrevotesAny",
        "UponProposalInPrevoteOrCommitAndPrevote",
        "UponQuorumOfPrecommitsAny",
        "UponProposalInPrecommitNoDecision",
        "OnTimeoutPropose",
        "OnQuorumOfNilPrevotes",
        "OnRoundCatchup"
     }

(************************** INDUCTIVE INVARIANT *******************************)
EvidenceContainsMessages ==
  \* evidence contains only the messages from:
  \* msgsPropose, msgsPrevote, and msgsPrecommit
  /\ \A m \in evidencePropose:
       m \in msgsPropose[m.round]
  /\ \A m \in evidencePrevote:
       m \in msgsPrevote[m.round]
  /\ \A m \in evidencePrecommit:
       m \in msgsPrecommit[m.round]

NoFutureMessagesForLargerRounds(p) ==
  \* a correct process does not send messages for the future rounds
  \A r \in { rr \in Rounds: rr > round[p] }:
    /\ \A m \in msgsPropose[r]: m.src /= p
    /\ \A m \in msgsPrevote[r]: m.src /= p
    /\ \A m \in msgsPrecommit[r]: m.src /= p

NoFutureMessagesForCurrentRound(p) ==
  \* a correct process does not send messages in the future
  LET r == round[p] IN
    /\ Proposer[r] = p \/ \A m \in msgsPropose[r]: m.src /= p
    /\ \/ step[p] \in {"PREVOTE", "PRECOMMIT", "DECIDED"}
       \/ \A m \in msgsPrevote[r]: m.src /= p
    /\ \/ step[p] \in {"PRECOMMIT", "DECIDED"}
       \/ \A m \in msgsPrecommit[r]: m.src /= p

\* the correct processes never send future messages
AllNoFutureMessagesSent ==
  \A p \in Corr:
    /\ NoFutureMessagesForCurrentRound(p)
    /\ NoFutureMessagesForLargerRounds(p)

\* a correct process in the PREVOTE state has sent a PREVOTE message
IfInPrevoteThenSentPrevote(p) ==
  step[p] = "PREVOTE" =>
    \E m \in msgsPrevote[round[p]]:
      /\ m.id \in ValidValues \cup { NilValue }
      /\ m.src = p

AllIfInPrevoteThenSentPrevote ==
  \A p \in Corr: IfInPrevoteThenSentPrevote(p)

\* a correct process in the PRECOMMIT state has sent a PRECOMMIT message
IfInPrecommitThenSentPrecommit(p) ==
  step[p] = "PRECOMMIT" =>
    \E m \in msgsPrecommit[round[p]]:
      /\ m.id \in ValidValues \cup { NilValue }
      /\ m.src = p

AllIfInPrecommitThenSentPrecommit ==
  \A p \in Corr: IfInPrecommitThenSentPrecommit(p)

\* a process in the PRECOMMIT state has sent a PRECOMMIT message
IfInDecidedThenValidDecision(p) ==
  step[p] = "DECIDED" <=> decision[p] \in ValidValues

AllIfInDecidedThenValidDecision ==
  \A p \in Corr: IfInDecidedThenValidDecision(p)

\* a decided process should have received a proposal on its decision
IfInDecidedThenReceivedProposal(p) ==
  step[p] = "DECIDED" =>
    \E r \in Rounds: \* r is not necessarily round[p]
      /\ \E m \in msgsPropose[r] \intersect evidencePropose:
          /\ m.src = Proposer[r]
          /\ m.proposal = decision[p]
          \* not inductive: /\ m.src \in Corr => (m.validRound <= r)

AllIfInDecidedThenReceivedProposal ==
  \A p \in Corr:
    IfInDecidedThenReceivedProposal(p)

\* a decided process has received two-thirds of precommit messages
IfInDecidedThenReceivedTwoThirds(p) ==
  step[p] = "DECIDED" =>
    \E r \in Rounds:
      LET PV == {
        m \in msgsPrecommit[r] \intersect evidencePrecommit:
          m.id = decision[p]
      }
      IN
      Cardinality(PV) >= THRESHOLD2

AllIfInDecidedThenReceivedTwoThirds ==
  \A p \in Corr:
    IfInDecidedThenReceivedTwoThirds(p)

\* for a round r, there is proposal by the round proposer for a valid round vr
ProposalInRound(r, proposedVal, vr) ==
  \E m \in msgsPropose[r] \intersect evidencePropose:
    /\ m.src = Proposer[r]
    /\ m.proposal = proposedVal
    /\ m.validRound = vr

TwoThirdsPrevotes(vr, v) ==
  LET PV == { mm \in msgsPrevote[vr] \intersect evidencePrevote: mm.id = v } IN
  Cardinality(PV) >= THRESHOLD2

\* if a process sends a PREVOTE, then there are three possibilities:
\* 1) the process is faulty,
\* 2) the PREVOTE contains Nil,
\* 3) a) there is a proposal in an earlier (valid) round,
\*    b) there are two thirds of PREVOTES in that round.
IfSentPrevoteThenReceivedProposalOrTwoThirds(r) ==
  \A mpv \in msgsPrevote[r]:
    \* case 1
    \/ mpv.src \in Faulty
    \* case 2
    \/ mpv.id = NilValue
    \* case 3
    \//\ mpv.src \in Corr
      /\ mpv.id /= NilValue
      /\ \/ ProposalInRound(r, mpv.id, NilRound)
         \/ \E vr \in Rounds:
            \* condition 3a
            /\ vr < r
            /\ ProposalInRound(r, mpv.id, vr)
            \* condition 3b
            /\ TwoThirdsPrevotes(vr, mpv.id)

AllIfSentPrevoteThenReceivedProposalOrTwoThirds ==
  \A r \in Rounds:
    IfSentPrevoteThenReceivedProposalOrTwoThirds(r)

\* if a correct process has sent a PRECOMMIT, then there are two thirds,
\* either on a valid value, or a nil value
IfSentPrecommitThenReceivedTwoThirds ==
  \A r \in Rounds:
    \A mpc \in msgsPrecommit[r]:
      mpc.src \in Corr =>
        \/ /\ mpc.id \in ValidValues
           /\ LET PV == {
                m \in msgsPrevote[r] \intersect evidencePrevote: m.id = mpc.id
              }
              IN
              Cardinality(PV) >= THRESHOLD2
        \/ /\ mpc.id = NilValue
           /\ Cardinality(msgsPrevote[r] \intersect evidencePrevote) >= THRESHOLD2

\* if a correct process has sent a precommit message in a round, it should
\* have sent a prevote
IfSentPrecommitThenSentPrevote ==
  \A r \in Rounds:
    \A mpc \in msgsPrecommit[r]:
      mpc.src \in Corr =>
        \E m \in msgsPrevote[r]:
          m.src = mpc.src

\* there is a locked round if a only if there is a locked value
LockedRoundIffLockedValue(p) ==
  (lockedRound[p] = NilRound) <=> (lockedValue[p] = NilValue)

AllLockedRoundIffLockedValue ==
  \A p \in Corr:
    LockedRoundIffLockedValue(p)

\* when a process locked a round, it must have sent a precommit on the locked value.
IfLockedRoundThenSentCommit(p) ==
  lockedRound[p] /= NilRound
    => \E r \in { rr \in Rounds: rr <= round[p] }:
       \E m \in msgsPrecommit[r]:
         m.src = p /\ m.id = lockedValue[p]

AllIfLockedRoundThenSentCommit ==
  \A p \in Corr:
    IfLockedRoundThenSentCommit(p)

\* a process always locks the latest round, for which it has sent a PRECOMMIT
LatestPrecommitHasLockedRound(p) ==
  LET pPrecommits == {
    mm \in UNION { msgsPrecommit[r]: r \in Rounds }:
      mm.src = p /\ mm.id /= NilValue
  }
  IN
  pPrecommits /= {}
    => LET latest ==
         CHOOSE m \in pPrecommits:
           \A m2 \in pPrecommits:
             m2.round <= m.round
      IN
       /\ lockedRound[p] = latest.round
       /\ lockedValue[p] = latest.id

AllLatestPrecommitHasLockedRound ==
  \A p \in Corr:
    LatestPrecommitHasLockedRound(p)

\* Every correct process sends only one value or NilValue.
\* This test has quantifier alternation -- a threat to all decision procedures.
\* Luckily, the sets Corr and ValidValues are small.
\*
\* @type: ($round, $round -> Set($preMsg)) => Bool;
NoEquivocationByCorrect(r, msgs) ==
  \A p \in Corr:
    \E v \in ValidValues \union {NilValue}:
      \A m \in msgs[r]:
        \/ m.src /= p
        \/ m.id = v

\* a proposer nevers sends two values
\* @type: ($round, $round -> Set($proposeMsg)) => Bool;
ProposalsByProposer(r, msgs) ==
  \* if the proposer is not faulty, it sends only one value
  \E v \in ValidValues:
    \A m \in msgs[r]:
      \/ m.src \in Faulty
      \/ m.src = Proposer[r] /\ m.proposal = v

AllNoEquivocationByCorrect ==
  \A r \in Rounds:
    /\ ProposalsByProposer(r, msgsPropose)
    /\ NoEquivocationByCorrect(r, msgsPrevote)
    /\ NoEquivocationByCorrect(r, msgsPrecommit)

\* construct the set of the message senders
\* @type: (Set({ src: $process, a })) => Set($process);
Senders(M) == { m.src: m \in M }

\* A crucial lemma by Josef Widder:
\* If T + 1 processes precommit on the same value in a round, then in the future
\* rounds there are less than 2T + 1 prevotes for another value
PrecommitsLockValue ==
  \A r \in Rounds:
    \A v \in ValidValues:
      \/ LET Precommits == {
            m \in msgsPrecommit[r] \intersect evidencePrecommit:
              m.id = v /\ m.src \in Corr
         }
         IN
         Cardinality(Senders(Precommits)) < THRESHOLD1
      \/ \A fr \in Rounds, w \in Values:
          LET Prevotes == {
            m \in msgsPrevote[fr] \intersect evidencePrevote: m.id = w
          } IN
          (fr > r /\ w /= v) => (Cardinality(Senders(Prevotes)) < THRESHOLD2)

\* Another lemma by Josef Widder:
\* If a correct process precommits and locks a value,
\* it can later prevote on another value, only if it has seen 2T + 1 prevotes.
RelockValueIfEnoughPrevotes ==
  \A r1, r2 \in Rounds, p \in Corr, v1, v2 \in ValidValues:
    LET m1 == [ type |-> "PRECOMMIT", src |-> p, id |-> v1, round |-> r1 ] IN
    LET m2 == [ type |-> "PREVOTE", src |-> p, id |-> v2, round |-> r2 ] IN
      LET RelockedValue ==
        /\ r1 < r2
        /\ v1 /= v2
        /\ m1 \in msgsPrecommit[r1]
        /\ m2 \in msgsPrevote[r2]
      IN
      LET EnoughPrevotesInMiddle ==
        \E vr \in Rounds:
          /\ r1 <= vr /\ vr <= r2
          \* count prevotes in the middle round, excluding p
          /\ LET Prevotes == {
               m \in msgsPrevote[vr] \intersect evidencePrevote:
                 m.id = v2 /\ (m.src /= p \/ vr < r2)
             }
             IN
             /\ Cardinality(Prevotes) >= THRESHOLD2
             \* this majority must be backed by a proposal!
             /\ LET proposal == [
                    type |-> "PROPOSE", src |-> Proposer[r2], round |-> r2,
                    proposal |-> v2, validRound |-> vr
                ] IN
                proposal \in msgsPropose[r2]
      IN
      RelockedValue => EnoughPrevotesInMiddle

\* if validRound is defined, then there are two-thirds of PREVOTEs
AllIfValidRoundThenTwoThirds ==
  \A p \in Corr:
    LET vr == validRound[p] IN
      \/ vr = NilRound /\ validValue[p] = NilValue
      \/ LET PV == {
           m \in msgsPrevote[vr] \intersect evidencePrevote:
             m.id = validValue[p]
         } IN
         Cardinality(PV) >= THRESHOLD2
    
AllValidAndLocked ==
  \A p \in Corr:
    /\ validRound[p] >= lockedRound[p]
    /\ validRound[p] /= NilRound <=> validValue[p] /= NilValue
    /\ lockedValue[p] /= NilValue => validValue[p] /= NilValue

\* a valid round can be only set to a valid value that was proposed earlier
AllIfValidRoundThenProposal ==
  \A p \in Corr:
    \/ validRound[p] = NilRound
    \/ \E m \in msgsPropose[validRound[p]] \intersect evidencePropose:
         m.proposal = validValue[p]

\* a combination of all lemmas
Inv ==
    /\ EvidenceContainsMessages
    /\ AllNoFutureMessagesSent
    /\ AllIfInPrevoteThenSentPrevote
    /\ AllIfInPrecommitThenSentPrecommit
    /\ AllIfInDecidedThenReceivedProposal
    /\ AllIfInDecidedThenReceivedTwoThirds
    /\ AllIfInDecidedThenValidDecision
    /\ AllLockedRoundIffLockedValue
    /\ AllIfLockedRoundThenSentCommit
    /\ AllLatestPrecommitHasLockedRound
    /\ AllIfSentPrevoteThenReceivedProposalOrTwoThirds
    /\ IfSentPrecommitThenSentPrevote
    /\ IfSentPrecommitThenReceivedTwoThirds
    /\ AllNoEquivocationByCorrect
    /\ RelockValueIfEnoughPrevotes
    /\ AllIfValidRoundThenTwoThirds
    /\ AllValidAndLocked
    /\ AllIfValidRoundThenProposal
    /\ PrecommitsLockValue

\* this is the inductive invariant we like to check
TypedInv == TypeOK /\ Inv

(******************************** THEOREMS ************************************)
(* Under this condition, the faulty processes can decide alone *)
FaultyQuorum == Cardinality(Faulty) >= THRESHOLD2

(* The standard condition of the Tendermint security model *)
LessThanThirdFaulty == N > 3 * T /\ Cardinality(Faulty) <= T

(*
 TypedInv is an inductive invariant, provided that there is no faulty quorum.
 We run Apalache to prove this theorem only for fixed instances of 4 to 10 processes.
 (We run Apalache manually, as it does not parse theorem statements at the moment.)
 To get a parameterized argument, one has to use a theorem prover, e.g., TLAPS.
 *)
THEOREM TypedInvIsInductive ==
    \/ FaultyQuorum \* if there are 2 * T + 1 faulty processes, we give up
    \//\ Init => TypedInv
      /\ TypedInv /\ [Next]_vars => TypedInv'

(*
 There should be no fork, when there are less than 1/3 faulty processes.
 *)
THEOREM AgreementWhenLessThanThirdFaulty ==
    LessThanThirdFaulty /\ TypedInv => Agreement

(*
 In a more general case, when there are less than 2/3 faulty processes,
 there is either Agreement (no fork), or two scenarios exist:
 equivocation by Faulty, or amnesia by Faulty.
 *)
THEOREM AgreementOrFork ==
    ~FaultyQuorum /\ TypedInv => Accountability

=============================================================================

