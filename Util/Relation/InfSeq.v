(**
CoLoR, a Coq library on rewriting and termination.
See the COPYRIGHTS and LICENSE files.

- Sidi Ould-Biha, 2010-04-27

Definitions and properties of infinite sequences, possibly modulo some
relation. Uses classical logic and the axiom of indefinite
description. *)

Set Implicit Arguments.

Require Import RelUtil NatUtil List Path NatLeast LogicUtil ClassicUtil
  IndefiniteDescription.

Section S.

Variable A : Type.

(***********************************************************************)
(** building an infinite E-sequence from an infinite E!-sequence *)

Section TransIS.

  Variables (E : relation A) (h : nat -> A) (HEh : IS (E!) h).

  Lemma IS_tc : exists h', IS E h' /\ h' 0 = h 0.

  Proof.
    assert (exPath : forall i, exists l, path E (h i) (h (S i)) l).
    intros i. apply clos_trans_path; auto.
    pose (li := fun i =>
      projT1 (constructive_indefinite_description _ (exPath i))).
    pose (F := fun i => length (cons (h i) (li i))).

    assert (HFi : forall i, exists y, F i = S y).
    intro i. exists (length (li i)). auto.
    pose (F0 := fun i => Interval_list F i).
    pose (P := fun i j => fst (F0 j) <= i /\ i < snd (F0 j)).

    assert (HinT : forall k, fst (F0 k) < snd (F0 k)).
    induction k. simpl. destruct (HFi 0) as [y Hy]; rewrite Hy; omega.
    simpl. destruct (HFi (S k)) as [y Hy]; rewrite Hy; omega.

    assert (HPeq : forall i j k, P k i /\ P k j -> i = j).
    intros i j k H; unfold P in H. destruct H as [H H0]. destruct H0 as [H1 H2].
    destruct H as [H H0]. generalize (le_lt_trans _ _ _ H H2). intros H3.
    generalize (le_lt_trans _ _ _ H1 H0). intros H4.
    destruct (le_or_lt i j) as [H5 | H5]. case (le_lt_or_eq _ _ H5); try auto.
    clear H5 H1 H2 H3; intros H5. induction j. omega. simpl in H4.
    case (le_lt_or_eq _ _ (lt_n_Sm_le _ _ H5)); intros H1.
    rewrite (IHj (lt_trans _ _ _ (HinT j) H4) H1) in H1. omega.
    rewrite H1 in H4. omega.
    clear H1 H2 H4 H H0. induction i. omega. simpl in H3.
    case (le_lt_or_eq _ _ (lt_n_Sm_le _ _ H5)); intros H1.
    rewrite (IHi (lt_trans _ _ _ (HinT i) H3) H1) in H1. omega.
    rewrite H1 in H3; omega.

    assert (exP_F0 : forall i, exists j, P i j). intros i. apply int_exPi. auto.
    pose (F1 := fun i => projT1 (ch_min _ (exP_F0 i))).

    assert (HF0 : forall i, (snd (F0 i) - fst (F0 i) = F i)).
    induction i; auto. simpl. omega.
    pose (h' := fun i => let j := (F1 i) in let i' := i - (fst (F0 j)) in
      nth i' (h j :: li j) (h (S j))).

    assert (HT : forall i, F1 i <= F1 (S i) <= S (F1 i)). intros.

    assert (HSi : S i <= snd (F0 (F1 i))).
    generalize (ch_minP _ (exP_F0 i)). unfold P. intuition.
    destruct (le_lt_or_eq _ _ HSi) as [H0 | H0]. Focus 2.

    assert (PSi : P (S i) (S (F1 i))). unfold P. simpl. rewrite H0.
    split; try omega. destruct (HFi (S (F1 i))) as [y Hy]. rewrite Hy; omega.

    cut (F1 (S i) = S (F1 i)). intros HT; rewrite HT. split; omega.

    destruct (projT2 (ch_min _ (exP_F0 (S i)))) as [_ H1]. apply H1.
    split; auto. intros k. unfold P. intros H2.
    rewrite (HPeq _ _ _ (conj PSi H2)). omega.

    cut (F1 (S i) = F1 i). intros HT; rewrite HT. split; omega.

    assert (PSi : P (S i) (F1 i)). split; try omega.
    apply (@le_trans _ i); try omega. destruct (ch_minP _ (exP_F0 i)); hyp.
    destruct (projT2 (ch_min _ (exP_F0 (S i)))) as [_ H].
    apply H; split; try hyp.
    intros k Hk. rewrite (HPeq _ _ _ (conj PSi Hk)). omega.

    assert (DecFSi : forall i, F1 (S i) = F1 i \/ F1 (S i) = S (F1 i)).
    intros. destruct (HT i) as [Hi1 Hi2]. omega.

    assert (forall i, i - fst (F0 (F1 i)) < length (h (F1 i) :: li (F1 i))).
    intros i. destruct (ch_minP _ (exP_F0 i)) as [H1 H2].

    assert (H0 : i - fst (F0 (F1 i)) < snd (F0 (F1 i)) - fst (F0 (F1 i))).
    apply plus_lt_reg_l with (p := fst (F0 (F1 i))).
    rewrite le_plus_minus_r; auto.
    rewrite le_plus_minus_r; auto.
    apply (@le_trans _ _ _ H1 (@lt_le_weak _ _ H2)).
    apply (lt_le_trans _ _ _ H0). rewrite (HF0 (F1 i)). auto.

    exists h'; split; unfold h'.

    (* 1 *)
    intro i; destruct (DecFSi i) as [Hi | Hi]; rewrite Hi.

    assert (S (i - fst (F0 (F1 i))) < length (h (F1 i) :: li (F1 i))).
    generalize (H (S i)). rewrite Hi. rewrite <- minus_Sn_m. auto.
    destruct (ch_minP _ (exP_F0 i)). auto.

    rewrite <- minus_Sn_m. Focus 2. apply (proj1 (ch_minP _ (exP_F0 i))).
    generalize H0. set (k := i - fst (F0 (F1 i))). destruct k. simpl.
    intros. apply path_headP.
    apply (projT2 (constructive_indefinite_description _ (exPath (F1 i)))).
    simpl. intros. apply path_nth_inP with (x := (h (F1 i))); try omega.
    apply (projT2 (constructive_indefinite_description _ (exPath (F1 i)))).
    rewrite <- Hi. assert (S i = snd (F0 (F1 i))).
    destruct (ch_minP _ (exP_F0 i)) as [_ HT0].
    destruct (le_lt_or_eq _ _ (lt_le_S _ _ HT0)); try auto.

    cut (F1 (S i) = F1 i). rewrite Hi. intros. symmetry in H1. omega.

    assert (PSi : P (S i) (F1 i)). split; try omega; auto.
    apply (@le_trans _ i); try omega. destruct (ch_minP _ (exP_F0 i)); hyp.
    destruct (projT2 (ch_min _ (exP_F0 (S i)))) as [_ H1].
    apply H1; split; try hyp.
    intros k Hk. rewrite (HPeq _ _ _ (conj PSi Hk)). omega.

    assert (nth (S i - fst (F0 (F1 (S i)))) (h (F1 (S i)) :: li (F1 (S i)))
      (h (S (F1 (S i)))) = h (F1 (S i))).

    cut (S i - fst (F0 (F1 (S i))) = 0). intros. rewrite H1. simpl; auto.

    rewrite Hi, H0. simpl. omega.
    rewrite H1. clear H1. generalize (HF0 (F1 i)). unfold F. intros.

    cut (i - fst (F0 (F1 i)) = length (li (F1 i))).
    Focus 2. rewrite <- H0 in H1. rewrite <- minus_Sn_m in H1. simpl in H1.
    omega.
    apply (proj1 (ch_minP _ (exP_F0 i))).
    set (k := i - fst (F0 (F1 i))).

    assert (path E (h (F1 i)) (h (S (F1 i))) (li (F1 i))).
    apply (projT2 (constructive_indefinite_description _ (exPath (F1 i)))).

    destruct k. intros.  symmetry in H3.
    destruct (li (F1 i)). simpl. simpl in H3. rewrite Hi. auto.
    simpl in H3. absurd_arith. simpl. intros. 
    apply path_lastP with (x := (h (F1 i)));  auto. rewrite Hi. hyp.

    (* 2 *)
    cut ((F1 0) = 0). intro H0; rewrite H0; refl.
    assert (P00 : P 0 0). unfold P. simpl. split; try omega.
    destruct (HFi 0) as [k Hk]. rewrite Hk; omega.
    symmetry. apply le_n_O_eq. apply (is_min_ch (P 0) (exP_F0 0) 0 P00).
  Qed.

End TransIS.

(***********************************************************************)
(** building an infinite R-sequence modulo E from an infinite
E@R-sequence modulo E if E is transitive *)

Section ISModComp.

  Variables (E R : relation A) (f g : nat -> A)
    (hyp1 : ISMod E (E @ R) f g) (TE : transitive E).

  Lemma ISMod_comp : exists g', ISMod E R f g'.

  Proof.
    assert (Hi : forall i, exists x, E (f i) x /\ R x (f (S i))).
    intro. destruct (hyp1 i). destruct H0. exists x. split; intuition.
    apply TE with (g i); auto.
    pose (Hgi := fun i => (constructive_indefinite_description _ (Hi i))).
    exists (fun i => projT1 (Hgi i)). intro. apply (projT2 (Hgi i)).
  Qed.

End ISModComp.

(***********************************************************************)
(** building an infinite R-sequence modulo E from an infinite
E@R-sequence *)

Section ISCompSplit.

  Variables (E R : relation A) (f : nat -> A).

  Lemma ISComp_split : IS (E @ R) f ->  exists g, ISMod E R f g.

  Proof.
    intros.
    assert (Hi : forall i, exists x, E (f i) x /\ R x (f (S i))).
    intro. destruct (H i). exists x. intuition.
    pose (Hgi := fun i => constructive_indefinite_description _ (Hi i)).
    exists (fun i => projT1 (Hgi i)). intro. apply (projT2 (Hgi i)).
  Qed.

End ISCompSplit.

(***********************************************************************)
(** building an infinite R-sequence modulo E from an infinite
EUR-sequence modulo E with infinitely many R-steps *)

Section ISModUnion.

  Variables (E R : relation A) (f g : nat -> A)
    (hyp1 : ISMod E (E U R) f g)
    (hyp2 : forall i, exists j, i <= j /\ R (g j) (f (S j)))
    (TE : transitive E).

  Lemma ISMod_union : exists f', exists g', ISMod E R f' g'
    /\ forall i, (exists k, g' i = g k) /\ (exists k, f' i = f k).

  Proof.
    pose (reid := rec_ch_min _ hyp2).
    pose (g0 := fun i => (g (reid i))).
    pose (f0 := fun i => match i with 0 => f 0 | S j => (f (S (reid j))) end).
    pose (P := fun i j => i <= j /\ (R (g j) (f (S j)))).

    assert (E_gfi : forall i j, S (reid i) <= j -> j < (reid (S i)) ->
      E (g j) (f (S j))). intros i j le_Sij lt_jx.
    generalize (is_min_ch (P (S (reid i))) (hyp2 (S (reid i)))). unfold P.
    intros Hproj. generalize (Hproj j). intros HT. destruct (hyp1 j) as [_ ERj].
    destruct ERj; auto. destruct (lt_not_le _ _ lt_jx). apply HT. auto.

    assert (E_gf0 : forall j, j < (reid 0) -> E (g j) (f (S j))).
    intros j lt_jx. generalize (is_min_ch (P 0) (hyp2 0)). unfold P. intro HP.
    generalize (HP j). intro HPj. destruct (hyp1 j) as [_ ERj].
    destruct ERj; auto.
    destruct (lt_not_le _ _ lt_jx). apply HPj. split; auto. omega.

    assert (HEfgi : forall i j k,
      S (reid i) <= j -> j <= k  -> k <= reid (S i) -> E (f j) (g k)).
    intros i j k le_ij le_jk le_ki. induction k.
    rewrite <- (le_n_O_eq _ le_jk) in le_ij. destruct (le_Sn_O _ le_ij).
    destruct (le_lt_or_eq _ _ le_jk) as [HT | HT]. Focus 2. rewrite HT.
    apply (proj1 (hyp1 (S k))). apply TE with (g k).
    exact (IHk (lt_n_Sm_le _ _ HT) (@le_trans _ _ _ (le_n_Sn k) le_ki)).
    apply TE with (f (S k)). apply (E_gfi i k); try omega.
    apply (proj1 (hyp1 (S k))).

    assert (HEfg0 : forall j k, j <= k -> k <= reid 0 -> E (f j) (g k)).
    intros j k le_jk le_k0. induction k. rewrite <- (le_n_O_eq _ le_jk).
    apply (proj1 (hyp1 0)). destruct (le_lt_or_eq _ _ le_jk) as [HT | HT].
    Focus 2. rewrite HT. apply (proj1 (hyp1 (S k))).
    apply TE with (g k). apply IHk; omega. apply TE with (f (S k)).
    apply (E_gf0 k); try omega. apply (proj1 (hyp1 (S k))).

    assert (Rgf : forall i, R (g (reid i)) (f (S (reid i)))).
    intro i. induction i. Focus 2. destruct (rec_ch_minP P hyp2 i). hyp.
    simpl. destruct (ch_minP (P 0) (hyp2 0)). hyp.

    exists f0; exists g0. split. Focus 2. intro. split. exists (reid i). auto.
    destruct i. exists 0; auto. exists (S (reid i)). auto.
    intro. split. Focus 2. apply Rgf. destruct i. Focus 2. unfold f0, g0.
    apply (HEfgi i); auto.
    destruct (ch_minP (P (S (reid i))) (hyp2 (S (reid i)))) as [? _]. hyp.
    unfold f0, g0. apply HEfg0; omega.
  Qed.

End ISModUnion.

(***********************************************************************)
(** building an infinite E-sequence from an infinite R-sequence modulo
E if R@E << E *)

Section ISModCommute.

  Variables (E R : relation A) (f g : nat -> A)
    (hyp1 : ISMod E R f g) (hyp2 : R @ E @ R << E @ R).

  Lemma existEdom_proof :
    forall x i, R x (f (S i)) -> exists y, E x y /\ R y (f (S (S i))).

  Proof.
    intros. destruct (hyp1 (S i)). apply hyp2. exists (g (S i)).
    split; auto. exists (f (S i)). split; auto.
  Qed.

  Fixpoint ISOfISMod_rec n : { x : A * nat | R (fst x) (f (S (snd x))) } :=
    let P := fun x : A * nat => R (fst x) (f (S (snd x))) in
      match n with
        | S n' => let (t, Pt) := ISOfISMod_rec n' in
          let H := existEdom_proof Pt in 
            let s := constructive_indefinite_description _ H in 
              let (t', Pt') := s in (exist P (t', (S (snd t))) (proj2 Pt'))
        | 0 => (exist P (g 0, 0) (proj2 (hyp1 0)))
      end.

  Lemma ISOfISMod_rec_spec : forall i,
    E (fst (proj1_sig (ISOfISMod_rec i)))
    (fst (proj1_sig (ISOfISMod_rec (S i)))).

  Proof.
    induction i; simpl. destruct (constructive_indefinite_description
    _ (existEdom_proof (proj2 (hyp1 0)))) as [t Pt]. simpl. destruct Pt. auto.
    destruct (ISOfISMod_rec i) as [t Pt].
    destruct (constructive_indefinite_description
      _ (existEdom_proof Pt)) as [t' Pt']. simpl.
    destruct (constructive_indefinite_description
      _ (existEdom_proof (proj2 Pt'))) as [y Py]. simpl. exact (proj1 Py).
  Qed.

  Definition ISOfISMod n :=
    match n with
      | S n' => (fst (proj1_sig (ISOfISMod_rec n')))
      | 0 => f 0
    end.

  Lemma ISOfISMod_spec : IS E ISOfISMod.

  Proof.
    intro. case i. simpl. exact (proj1 (hyp1 O)).
    intros. unfold ISOfISMod. exact (ISOfISMod_rec_spec n).
  Qed.

End ISModCommute.

(***********************************************************************)
(** building an infinite R-sequence modulo E! from an infinite
R-sequence modulo E# *)

Section ISModTrans.

  Variables (E R : relation A) (f g : nat -> A)
    (hyp1 : ISMod (E #) R f g) (NISR : forall h, ~IS R h)
    (TrsR : transitive R).

  Lemma build_trs_proof : forall i, exists j, i <= j /\ E! (f j) (g j).

  Proof.
    intro i. apply not_all_not_ex. intro HTF. induction i.
    assert (HT : IS R g). intro k. generalize (hyp1 (S k)).
    generalize (HTF (S k)). rewrite not_and_eq. intro HT.
    destruct HT as [HT | HT]. destruct (HT (le_O_n (S k))). intro HT0.
    destruct (rtc_split (proj1 HT0)) as [HT1 | HT1]. rewrite <- HT1.
    apply (proj2 (hyp1 k)). tauto. apply (@NISR g). hyp.
    assert (HT : forall j, ~ ((E !) (f (S i + j)) (g (S i + j)))).
    intro j. generalize (HTF (S i + j)). apply contraposee_inv. intro HT.
    split; try omega. hyp.
    assert (HT0 : forall j, (f (S i + j)) = (g (S i + j))).
    intro j. destruct (rtc_split (proj1 (hyp1 (S i + j)))); auto.
    destruct (HT j); auto.
    pose (h := fun j => g (S i + j)).
    assert (IS R h). intro j. unfold h. rewrite <- (HT0 (S j)).
    generalize (proj2 (hyp1 (S i + j))). rewrite <- plus_Snm_nSm. simpl. auto.
    generalize H. apply NISR.
  Qed.

  Lemma trc_ISMod : exists f', exists g', ISMod (E!) R f' g' /\
    (exists k, g' 0 = g k) /\ (f' 0 = f 0 \/ R (f 0) (f' 0)).

  Proof.
    set (HexP := build_trs_proof). pose (reid := rec_ch_min _ HexP).
    pose (f0 := fun i => f (reid i)). pose (g0 := fun i => g (reid i)).

    assert (eq_fg0 : forall j, j < reid 0 -> (f j) = (g j)).
    intros j lt_j0. generalize (is_min_ch _ (HexP 0)). intros Hproj.
    generalize (Hproj j). intros HT. cut (E # (f j) (g j)).
    intros HT0. destruct (rtc_split HT0) as [| HT1]; auto.
    destruct (le_not_lt _ _ (HT (conj (le_O_n j) HT1))). hyp.
    apply (proj1 (hyp1 j)).

    assert (eq_fgi : forall i j,
      S (reid i) <= j -> j < (reid (S i)) -> (f j) = (g j)).
    intros i j. simpl. intros le_Sij lt_jx.
    generalize (is_min_ch _ (HexP (S (reid i)))). intros Hproj.
    generalize (Hproj j). intros HT. cut (E # (f j) (g j)).
    intros HT0. destruct (rtc_split HT0) as [| HT1]; auto.
    destruct (le_not_lt _ _ (HT (conj le_Sij HT1))). hyp.
    apply (proj1 (hyp1 j)).

    assert (HEfg : forall i, (E !) (f (reid i)) (g (reid i))).
    intro i. induction i. Focus 2. destruct (rec_ch_minP  _ HexP i); hyp.
    destruct (ch_minP _ (HexP 0)); hyp.

    assert (HRfg : forall i j k, (reid i) <= j -> j < k  -> k <= reid (S i) ->
      R (g j) (f k)).
    intros i j k le_ij lt_jk le_ki. induction k. destruct (lt_n_O _ lt_jk).
    destruct (le_lt_or_eq _ _ (lt_n_Sm_le _ _ lt_jk)) as [HT | HT]. Focus 2.
    rewrite HT. apply (proj2 (hyp1 k)).
    apply (@TrsR _ (f k)). apply IHk; try omega.
    rewrite (eq_fgi i k); try omega.
    apply (proj2 (hyp1 k)).

    assert (HRfg0 : forall j k, j < k  -> k <= reid 0 -> R (g j) (f k)).
    intros j k lt_jk le_k0. induction k. destruct (lt_n_O _ lt_jk).
    destruct (le_lt_or_eq _ _ (lt_n_Sm_le _ _ lt_jk)) as [HT | HT]. Focus 2.
    rewrite HT. apply (proj2 (hyp1 k)).
    apply (@TrsR _ (f k)). apply IHk; try omega. rewrite (eq_fg0 k); try omega.
    apply (proj2 (hyp1 k)).

    exists f0; exists g0. split. intro i. simpl. unfold f0, g0. split.
    apply HEfg.
    apply (HRfg i); auto. destruct (rec_ch_minP _ HexP i) as [HT _].
    apply (lt_le_trans (reid i) (S (reid i)) (reid (S i))); auto.
    split. exists (reid 0). simpl. auto.
    unfold f0. case_eq (reid 0). left; refl. right.
    rewrite (eq_fg0); try omega. apply HRfg0; omega.
  Qed.

End ISModTrans.

(***********************************************************************)
(** building an infinite R-sequence from an infinite E#R-sequence if
R@E<<R *)

Section absorb.

  Variables (E R : relation A).

  Lemma IS_absorb : R @ E << R -> EIS (E# @ R) -> EIS R.

  Proof.
    intros ab [f hf]. destruct (ISComp_split hf) as [g H]. exists g.
    intro i. ded (H i). ded (H (S i)). eapply incl_comp_rtc. apply ab.
    exists (f (S i)). intuition.
  Qed.

End absorb.

End S.