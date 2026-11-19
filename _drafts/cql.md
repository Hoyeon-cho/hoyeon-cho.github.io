---
title: "CQL: Conservative Q-Learning (오프라인 강화학습)"
date: 2026-11-12 12:00:00 +0900
categories: ["강화학습"]
tags: ["강화학습", "오프라인RL", "CQL", "머신러닝"]
description: "오프라인 강화학습에서 Q값 과대평가를 막는 CQL(Conservative Q-Learning)을 정리한다."
math: true
---
---

## 0. 알고리즘 전체 진행 순서 (Overview)

> "결과부터 먼저 보고, 이 알고리즘이 내부적으로 어떻게 굴러가는지 파악하자."

보수적 Q-러닝(Conservative Q-Learning, CQL)의 핵심 학습 파이프라인을 친화적인 단계별 흐름으로 먼저 정리한다:

1. 초기 설정 (Initialization)
   - 파라미터 $\theta$를 가지는 2개의 Critic Q-신경망 $Q_{\theta_1}, Q_{\theta_2}$ 초기화
   - 안정적인 타깃 계산을 위한 타깃 Q-신경망 $\bar{\theta}_1 \leftarrow \theta_1, \; \bar{\theta}_2 \leftarrow \theta_2$ 복제
   - 파라미터 $\phi$를 가지는 Actor 정책 신경망 $\pi_\phi$ 초기화
   - 추가적인 환경 상호작용 없이 이미 수집 완료된 정적 오프라인 데이터셋 $\mathcal{D}$ 준비
   - 보수성 가중치 하이퍼파라미터 $\alpha > 0$ 설정

2. 오프라인 학습 루프 (매 학습 스텝마다)
   추가적인 환경 상호작용 없이 오직 고정된 데이터셋 $\mathcal{D}$만을 활용하여 다음 5단계를 반복한다:

   - 1단계: 미니배치 샘플링 (Batch Sampling)
     정적 데이터셋 $\mathcal{D}$로부터 $B$개의 전이 표본 $(s, a, r, s')$을 무작위 추출한다.

   - 2단계: 보수적 Q-함수 손실(CQL Loss) 계산
     각 상태 $s$에 대해 모든 행동의 Soft-max 가치(Log-Sum-Exp)를 억누르고, 실제 데이터셋에 존재하는 행동의 Q값은 끌어올리는 보수적 정규화 손실을 구성한다:
     $$
J_Q(\theta_i) = \frac{1}{2}\mathbb{E}_{(s,a,r,s') \sim \mathcal{D}}\left[\left(Q_{\theta_i}(s, a) - y\right)^2\right] + \alpha \mathbb{E}_{s \sim \mathcal{D}}\left[\log \sum_a \exp(Q_{\theta_i}(s, a)) - \mathbb{E}_{a \sim \mathcal{D}}[Q_{\theta_i}(s, a)]\right]
$$
     (단, 타깃 가치 $y = r + \gamma \min_{j=1,2} Q_{\bar{\theta}_j}(s', a') - \alpha_{\text{sac}} \log \pi_\phi(a' \mid s')$ 이다.)

   - 3단계: Critic 신경망 업데이트
     표준 옵티마이저(Adam)를 통해 두 Q-신경망 파라미터 $\theta_1, \theta_2$를 각각 경사하강법으로 갱신한다.

   - 4단계: Actor 정책 신경망 업데이트
     보수적으로 학습된 Q-함수의 가치를 최대화하도록 정책 파라미터 $\phi$를 최적화한다:
     $$
J_\pi(\phi) = \mathbb{E}_{s \sim \mathcal{D}, a \sim \pi_\phi}\left[\alpha_{\text{sac}} \log \pi_\phi(a \mid s) - \min_{i=1,2} Q_{\theta_i}(s, a)\right]
$$

   - 5단계: 타깃 신경망 소프트 업데이트 (Polyak Averaging)
     타깃 Q-신경망을 지수이동평균(EMA)으로 서서히 동기화한다:
     $$
\bar{\theta}_i \leftarrow \tau \theta_i + (1 - \tau) \bar{\theta}_i \quad (i = 1, 2)
$$

이제 왜 이런 목적함수가 나왔는지, 기존 오프라인 RL의 한계부터 하나씩 뜯어보자.

---

## 1. 서론: 왜 오프라인 강화학습인가? (Motivation)

지금까지 살펴본 PPO나 SAC은 훌륭한 알고리즘이지만, 한 가지 전제 조건이 있다:
"에이전트가 환경과 직접 부딪히며 무수한 시행착오(Trial-and-Error)를 겪을 수 있어야 한다."

하지만 현실의 많은 문제는 자유로운 온라인 시행착오를 허락하지 않는다:
- 자율주행차가 보상을 찾겠다고 무작정 벽을 들이받거나 신호를 위반할 수 없다.
- 병원의 환자 치료 시스템이 최적 처방을 찾겠다고 임의의 약물을 과다 투여해볼 수 없다.
- 수억 원을 호가하는 산업용 로봇 팔이 파라미터를 맞추겠다고 고속으로 바닥에 내리꽂힐 수 없다.

이 때문에 실세계에서는 이미 사람이 조종했거나 과거의 규칙 기반 제어기로 수집해 둔 고정된 데이터셋 $\mathcal{D}$만 보고 최적의 정책을 찾아내는 오프라인 강화학습(Offline RL)이 필연적으로 요구된다.

---

## 2. 기존 Q-러닝의 문제: 분포 변화와 외삽 오차

단순히 생각하면 "SAC이나 DQN 같은 Off-policy 알고리즘은 리플레이 버퍼를 쓰니까, 그냥 정적 데이터셋만 집어넣고 학습시키면 되는 것 아닌가?"라고 생각할 수 있다.

하지만 기존 Q-러닝을 고정된 데이터셋에 그대로 돌리면 성능이 크게 무너진다.
그 원인은 데이터 편향 자체라기보다는, 편향된 데이터 + $\max$ 연산자의 탐욕 + 현실 피드백의 부재라는 삼중 결합 때문이다.

### 2.1 지도학습과의 차이와 외삽 오차 (Extrapolation Error)

만약 우리가 하려는 것이 단순히 "사람의 행동을 그대로 따라 하는 행동 복제(Behavioral Cloning)"였다면, 데이터가 편향되어 있어도 큰 문제가 없다. 데이터에 있는 행동만 그대로 모방하면 되기 때문이다.

하지만 강화학습의 목표는 "데이터셋보다 더 뛰어난 최적의 정책"을 찾는 것이다.
따라서 Q-러닝은 필연적으로 데이터셋에 없는 미지의 행동(Out-of-Distribution, OOD Action)의 가치까지 탐색하게 된다.

신경망은 본 적 없는 OOD 행동을 만났을 때 겸손하게 "모른다"고 답하지 않는다.
복잡한 비선형 곡면 특성상, 우연히 엉뚱한 행동에 대해 실제 가치보다 훨씬 큰 양수의 가치를 출력해버릴 수 있다. 이를 외삽 오차(Extrapolation Error)라고 부른다.

### 2.2 오차의 비대칭성 (과소평가 vs 과대평가)

여기서 가장 중요한 핵심은 오차의 비대칭성이다:

- 만약 신경망이 미지의 행동을 과소평가(Underestimation)한다면?
  점수가 실제보다 낮게 나오므로 $\max$ 연산자는 그 행동을 거들떠보지도 않는다. 에이전트는 데이터셋에 있는 안전한 행동을 고르게 되므로 아무런 사고가 발생하지 않는다. 무해한 오차다.

- 하지만 단 한 번이라도 과대평가(Overestimation)를 한다면?
  수많은 미지의 행동 중 딱 하나라도 우연히 점수가 높게 튀어 오르는 순간, $\max$ 연산자가 그 허풍 행동을 즉시 낚아채 벨만 타깃으로 삼아버린다.

### 2.3 왜 과대평가는 피하기 어려운가? (옌센 부등식)

"신경망이 운 좋게 과대평가를 안 할 수도 있지 않은가?"라고 반문할 수 있다.
이전에 다루었던 옌센 부등식(Jensen's Inequality)을 떠올려보자. $\max$는 볼록 함수이므로, 노이즈가 섞인 추정치에 $\max$를 취하면 평균적으로 위쪽으로 치우친다:

$$
\mathbb{E}\left[\max_a \hat{Q}(s, a)\right] \ge \max_a \mathbb{E}\left[\hat{Q}(s, a)\right]
$$

신경망의 예측 오차 평균이 0이라 하더라도($\mathbb{E}[\text{noise}] = 0$), 수많은 행동 후보군에 대해 $\max$를 취하는 순간 가장 양수 쪽으로 크게 튄 극단적인 오차 노이즈가 선택된다.
후보 행동이 많을수록 우연히 크게 튀는 행동이 하나쯤 섞여 있을 가능성도 커진다. 연속 행동 공간이라면 더 말할 것도 없다.

온라인 RL에서는 실제로 그 행동을 취해보고 벌점을 맞으며 허풍을 깨부수는 자가 교정(Self-correction)이 가능했지만, 오프라인 RL에는 현실 피드백이 전무하다.
결국 이 과대평가가 벨만 업데이트를 타고 눈덩이처럼 불어나, 정책을 엉뚱한 방향으로 끌고 간다.

기존 연구들(BCQ, BEAR 등)은 정책이 데이터 분포를 벗어나지 못하도록 정책 자체를 강제로 묶어두는 방식(Policy Constraint)을 시도했다. 하지만 행동 분포를 추정하기 위한 생성 모델(VAE 등)이 추가로 필요했고, 데이터셋보다 크게 나은 정책을 찾기는 어려웠다.

---

## 3. CQL의 발상의 전환: Q-함수 자체를 보수적으로 만들어라

CQL 저자들은 정책을 가두는 대신 다른 시각을 제시했다:
> "정책을 굳이 틀어막지 말자. 대신 신경망이 평가하는 Q-함수 자체가 실제 가치를 절대 넘지 못하도록, Q-함수를 보수적인 하한선(Lower Bound)으로 학습시키면 되지 않는가?"

여기서 '하한선(Lower Bound)'이라는 용어의 주어와 목적어를 명확히 짚고 넘어갈 필요가 있다:
- 신경망 $\hat{Q}$의 관점에서 보면: 실제 참값 $Q^\pi$는 절대 뚫고 올라가면 안 되는 천장(상한선, Upper bound)이다 ($\hat{Q} \le Q^\pi$).
- 하지만 실제 참 가치 $Q^\pi$의 관점에서 보면: 우리가 학습한 $\hat{Q}$는 아무리 못해도 이 점수 이상은 나온다는 바닥(하한선, Lower bound) 역할을 한다 ($Q^\pi \ge \hat{Q}$).

즉, "내가 계산한 보수적 예측치가 80점이라면, 실제 로봇에 올렸을 때 성능은 최소한 80점 이상은 무조건 보장된다"는 안전 보장(Safety Guarantee)을 뜻하므로 이를 하한선이라 부른다.

그렇다면 Q-함수의 하한선은 어떻게 유도할 수 있을까?

---

### 3.1 단순 보수적 평가 (Pointwise Lower Bound): 두 힘의 줄다리기

가장 직관적인 방법은 표준 벨만 오차를 최소화하면서, 특정 행동 분포 $\mu(a|s)$에서 나오는 Q값의 크기 자체를 무조건 깎아내리는 것이다:

$$
\hat{Q}_{k+1} \leftarrow \arg\min_Q \Big( \underbrace{\alpha \mathbb{E}_{s \sim \mathcal{D}, a \sim \mu(a|s)}[Q(s, a)]}_{\text{1번 항: 아래로 찍어 누르는 보수적 힘}} + \underbrace{\frac{1}{2}\mathbb{E}_{s, a, s' \sim \mathcal{D}}\left[\left(Q(s, a) - \hat{\mathcal{B}}^\pi \hat{Q}_k(s, a)\right)^2\right]}_{\text{2번 항: 벨만 타깃에 맞추려는 원래의 힘}} \Big)
$$

(단, $\hat{\mathcal{B}}^\pi \hat{Q}_k(s, a) = r(s, a) + \gamma \mathbb{E}_{a' \sim \pi}[\hat{Q}_k(s', a')]$는 데이터셋 표본 기반의 경험적 벨만 연산자이다.)

이 식은 서로 반대 방향으로 당기는 두 힘의 줄다리기다:
- 2번 항: 기존 Q-러닝처럼 벨만 타깃과의 오차 제곱을 줄여 정상적인 가치 학습을 수행하려 한다.
- 1번 항: 목적함수가 $\arg\min_Q$이므로, $Q(s, a)$ 값 자체를 강제로 바닥으로 끌어내린다. $\alpha > 0$는 이 페널티의 세기다.
- $\mu(a|s)$: 데이터셋에 없는 미지의 행동(OOD)이나 현재 정책 $\pi$의 행동 분포다.

이 식의 최적해를 직관적으로 이해하기 위해 $Q(s, a)$에 대해 편미분하여 0으로 두면 다음과 같은 관계식이 나온다:

$$
Q(s, a) \approx \hat{\mathcal{B}}^\pi \hat{Q}_k(s, a) - \alpha \frac{\mu(a|s)}{\hat{\pi}_\beta(a|s)}
$$

이 식이 말하는 바는 다음과 같다:
벨만 업데이트를 거칠 때마다 $\alpha \frac{\mu}{\hat{\pi}_\beta}$라는 양수 페널티가 강제로 차감된다!
업데이트가 누적되어 수렴하면, $\alpha$가 충분히 클 때 최종 Q값은 참값보다 아래쪽에 형성된다:
$$
\forall s \in \mathcal{D}, a, \quad \hat{Q}^\pi(s, a) \le Q^\pi(s, a) \quad (\text{Theorem 3.1})
$$

하지만 이 방식에는 부작용이 있다.
모든 행동의 Q값을 무작정 깎아내리기 때문에, 실제로 좋은 행동들까지 지나치게 저평가되어 정책이 아무것도 하지 않으려는 '과도한 비관주의(Over-conservatism)'에 빠지게 된다.

---

### 3.2 개선된 보수적 평가 (Tighter Expected Lower Bound)

우리가 진정으로 원하는 것은 모든 점 $(s, a)$에서 빡빡하게 낮추는 것이 아니라, 현재 정책 $\pi$가 얻게 될 기대 가치 $V^\pi(s) = \mathbb{E}_{a \sim \pi}[Q(s, a)]$의 과대평가만 핀포인트로 막는 것이다.

이를 위해 CQL은 한 가지 트릭을 쓴다:
"미지의 행동은 아래로 누르되, 실제 데이터셋에 있는 검증된 행동($a \sim \hat{\pi}_\beta$)의 Q값은 반대로 위로 끌어올린다!"

$$
\hat{Q}_{k+1} \leftarrow \arg\min_Q \alpha \left( \mathbb{E}_{s \sim \mathcal{D}, a \sim \mu(a|s)}[Q(s, a)] - \mathbb{E}_{s \sim \mathcal{D}, a \sim \hat{\pi}_\beta(a|s)}[Q(s, a)] \right) + \frac{1}{2}\mathbb{E}_{s, a, s' \sim \mathcal{D}}\left[\left(Q(s, a) - \hat{\mathcal{B}}^\pi \hat{Q}_k(s, a)\right)^2\right]
$$

(여기서 $\hat{\pi}_\beta(a|s)$는 데이터셋 $\mathcal{D}$를 생성한 행동 분포이다.)

이 식의 효과는 다음과 같다:
1. 앞쪽 항($\mathbb{E}_\mu[Q]$)은 미지의 위험한 행동의 Q값을 찍어 누른다.
2. 뒤쪽 항($-\mathbb{E}_{\hat{\pi}_\beta}[Q]$)은 마이너스 부호가 붙어 있으므로, 데이터셋에 실제로 관측된 안전한 행동의 Q값은 오히려 높이 평가하도록 끌어올린다.

논문의 [Theorem 3.2]에 따르면, $\mu = \pi$로 설정할 경우 개별 점 $(s, a)$ 단위에서는 하한이 아닐지라도, 정책이 취할 기댓값 기준으로는 하한이 보장된다 (역시 $\alpha$가 충분히 클 때):
$$
\mathbb{E}_{a \sim \pi(a|s)}\left[\hat{Q}^\pi(s, a)\right] \le V^\pi(s)
$$

실제 데이터에 존재하는 행동의 가치는 정상적으로 인정해주면서, 엉뚱한 행동만 핀포인트로 페널티를 주므로 훨씬 더 타이트하고 유용한 가치 추정이 가능해진다.

---

## 4. Log-Sum-Exp의 유도: CQL(H)

이제 남은 질문은 이것이다:
"도대체 어떤 행동 분포 $\mu(a|s)$의 Q값을 가장 집중적으로 끌어내려야 하는가?"

당연히 현재 Q-함수가 가장 높게 평가하고 있는 위험한 행동들을 최우선적으로 끌어내려야 한다.
즉, $\mu$ 자체가 Q값을 최대로 만드는 최악의 적대자(Adversary)가 되도록 다음과 같은 Min-Max 최적화 문제(CQL(R))를 구성한다:

$$
\min_Q \max_\mu \alpha \left( \mathbb{E}_{s \sim \mathcal{D}, a \sim \mu(a|s)}[Q(s, a)] - \mathbb{E}_{s \sim \mathcal{D}, a \sim \hat{\pi}_\beta(a|s)}[Q(s, a)] \right) + \frac{1}{2}\mathbb{E}\left[\left(Q - \hat{\mathcal{B}}^\pi \hat{Q}_k\right)^2\right] + R(\mu)
$$

여기서 정규화 항 $R(\mu)$를 균등 분포(Uniform Distribution)와의 KL 발산($R(\mu) = -D_{KL}(\mu \parallel \text{Unif})$)으로 두면 어떻게 될까?

내부의 $\max_\mu$ 최적화 문제는 우리가 잘 알고 있는 볼츠만(Softmax) 분포의 닫힌 형태(Closed-form) 해를 갖게 된다:
$$
\mu^*(a|s) \propto \exp(Q(s, a))
$$

이 최적의 $\mu^*$를 다시 목적함수에 대입하면, 정보이론과 기계학습에서 자주 등장하는 Log-Sum-Exp(소프트맥스 가치) 식이 유도된다:

$$
\min_Q \alpha \mathbb{E}_{s \sim \mathcal{D}}\left[ \log \sum_a \exp(Q(s, a)) - \mathbb{E}_{a \sim \hat{\pi}_\beta(a|s)}[Q(s, a)] \right] + \frac{1}{2}\mathbb{E}_{(s,a,s') \sim \mathcal{D}}\left[\left(Q(s, a) - \hat{\mathcal{B}}^\pi \hat{Q}_k(s, a)\right)^2\right]
$$

이것이 바로 논문에서 가장 핵심적으로 사용되는 CQL(H) 목적함수이다!

이 식의 물리적 의미는 다음과 같다:
- $\log \sum_a \exp(Q(s, a))$: 상태 $s$에서 취할 수 있는 모든 행동들의 Q값 중 큰 값들을 강력하게 억누르는 소프트맥스 최대치 항이다.
- $\mathbb{E}_{a \sim \hat{\pi}_\beta}[Q(s, a)]$: 반면 데이터셋에 있는 행동의 가치는 적극적으로 지켜주는 항이다.

---

## 5. CQL이 보장하는 3가지 핵심 수학적 성질

CQL이 오프라인 강화학습의 대표 베이스라인이 된 데에는 다음 3가지 이론적 성질이 한몫했다.
( 단, 이 정리들은 tabular 또는 선형 근사 같은 가정과 "$\alpha$가 충분히 크다"는 조건 아래에서 증명된 것이다. 심층 신경망에서 그대로 보장되는 것은 아니다. )

### 1) 가치 하한 보장 (Lower-Bound Guarantee)
표본 오차가 있더라도, $\alpha$가 충분히 크면 학습된 Q-함수는 실제 정책 가치의 하한이 된다. 과대평가가 쌓여 정책이 망가지는 경로를 막는 것이다.

### 2) 간격 확장성 (Gap-Expanding Property, Theorem 3.4)
데이터셋에 존재하는 정상적인 행동과, 데이터셋에 없는 위험한 OOD 행동 사이의 Q값 격차(Gap)를 참 가치보다 더 크게 벌려놓는다:
$$
\mathbb{E}_{\pi_\beta}[\hat{Q}(s, a)] - \mathbb{E}_\mu[\hat{Q}(s, a)] > \mathbb{E}_{\pi_\beta}[Q(s, a)] - \mathbb{E}_\mu[Q(s, a)]
$$
이로 인해 정책 최적화 과정에서 에이전트는 미경험 행동을 기웃거리지 않고 안전한 행동을 자연스럽게 우선 선택하게 된다.

### 3) 안전한 정책 개선 보장 (Safe Policy Improvement, Theorem 3.6)
CQL을 통해 도출된 정책 $\pi^*$는 고정된 데이터셋을 생성한 행동 정책 $\hat{\pi}_\beta$보다 실제 환경에서 성능이 떨어지지 않음을 높은 확률($\ge 1 - \delta$)로 보장한다.

---

## 6. 실전 연속 행동 공간에서의 구현: CQL-SAC

로봇 제어와 같은 연속 행동 공간($a \in \mathbb{R}^d$)에서는 모든 행동에 대한 합인 $\sum_a \exp(Q(s, a))$ 적분을 직접 계산할 수 없다.

실전 구현에서는 이를 몬테카를로 중요도 샘플링(Importance Sampling)으로 근사한다. 상태 $s$마다 다음 세 가지 분포에서 총 $N$개의 행동을 섞어서 샘플링한 뒤 로그합을 계산한다:
1. 행동 공간 전체를 고르게 덮는 균등 분포(Uniform Distribution) 표본
2. 현재 정책 신경망 $\pi_\phi(\cdot \mid s)$에서 뽑은 표본
3. 다음 상태 정책 $\pi_\phi(\cdot \mid s')$에서 뽑은 표본

이렇게 구한 보수적 Q-손실함수를 비평가(Critic)에 적용하고, 액터(Actor)는 표준 SAC과 동일하게 Reparameterization Trick을 사용해 Q값을 최대화하도록 업데이트한다. 이것이 연구에서 흔히 쓰이는 CQL-SAC 구조다.

---

## 7. 맺음말

CQL을 한 문장으로 정리하면 다음과 같다.

"모르는 행동은 일단 낮게 쳐라"

정책을 직접 묶지 않고 Q-함수를 보수적으로 깎아내리는 것만으로 오프라인 학습을 안정화했다는 점이 이 논문의 핵심이라 생각한다.

<!-- 학습 메모 (발행 전 삭제)
- 점별 하한(Theorem 3.1)에서 기대 가치 하한(Theorem 3.2)으로 넘어갈 때, 데이터셋 행동의 Q값을 끌어올려도 하한이 유지되는 이유
- R(mu)에 KL 정규화를 넣었을 때 볼츠만 분포와 Log-Sum-Exp가 나오는 과정 (라그랑주 / 쌍대성 글과 연결 예정)
- 실제 로봇 데이터셋에서 alpha 조율 방법
-->
