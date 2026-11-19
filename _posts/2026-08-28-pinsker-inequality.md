---
title: "핀스커(Pinsker) 부등식"
date: 2026-08-28 17:06:40 +0900
categories: ["수학 및 알고리즘"]
tags: ["부등식", "확률 분포 거리"]
description: "TV 거리와 KL 발산 사이의 관계인 핀스커 부등식을 로그합 부등식과 테일러 전개로 증명한다."
math: true
---
👉 선행 개념: [Total Variation Distance](/posts/total-variation-distance/), [KL Divergence](/posts/kl-divergence/), [테일러 급수와 나머지 항 정리](/posts/taylor-series-remainder/), [로그합 부등식](/posts/log-sum-inequality/)

## 1. 정의

임의의 두 확률 분포 $P, Q$에 대해 다음 부등식이 항상 성립한다:

$$
D_{TV}(P, Q) \le \sqrt{\frac{1}{2} D_{KL}(P \parallel Q)}
$$

이 부등식은 **정보이론적 척도인 KL 발산(KL Divergence)**과 **직관적 확률 차이 척도인 전변차 거리(Total Variation Distance)** 사이의 명확한 상한/하한 관계를 이어주는 핵심 연결고리이다.

증명 과정이 다소 길기 때문에 2단계로 나누어 차근차근 증명한다.

---

## 2.1 KL 발산과 사건의 분할 (로그합 부등식 활용)

전체 표본 공간을 임의의 사건 집합 $A$와 그 여집합 $A^c$라는 $2$개의 큰 사건으로 이분할하자.

이때 각 사건에 대한 확률을 다음과 같이 정의한다:

$$
P_1 = P(A) = \sum_{x \in A} p(x), \quad Q_1 = Q(A) = \sum_{x \in A} q(x)
$$
$$
P_2 = P(A^c) = \sum_{x \in A^c} p(x), \quad Q_2 = Q(A^c) = \sum_{x \in A^c} q(x)
$$

(단, $P_1 + P_2 = 1, Q_1 + Q_2 = 1$이다.)

그러면 두 분포의 KL 발산에 대해 다음 부등식이 성립한다:

$$
D_{KL}(P \parallel Q) \ge P_1 \ln \frac{P_1}{Q_1} + P_2 \ln \frac{P_2}{Q_2}
$$

### [증명]


앞선 글에서 증명한 **로그합 부등식(Log-Sum Inequality)**은 다음과 같다:

$$
\sum_{i} a_i \ln \frac{a_i}{b_i} \ge \left(\sum_i a_i\right) \ln \frac{\sum_i a_i}{\sum_i b_i}
$$

확률은 항상 $0$ 이상이므로 사건 $A$와 $A^c$에 대해 로그합 부등식을 각각 적용할 수 있다:

$$
\sum_{x \in A} p(x) \ln \frac{p(x)}{q(x)} \ge \left(\sum_{x \in A} p(x)\right) \ln \frac{\sum_{x \in A} p(x)}{\sum_{x \in A} q(x)} = P_1 \ln \frac{P_1}{Q_1}
$$
$$
\sum_{x \in A^c} p(x) \ln \frac{p(x)}{q(x)} \ge \left(\sum_{x \in A^c} p(x)\right) \ln \frac{\sum_{x \in A^c} p(x)}{\sum_{x \in A^c} q(x)} = P_2 \ln \frac{P_2}{Q_2}
$$

위 두 식의 양변을 서로 더하면 다음과 같이 증명이 완성된다:

$$
D_{KL}(P \parallel Q) = \sum_{x \in X} p(x) \ln \frac{p(x)}{q(x)} \ge P_1 \ln \frac{P_1}{Q_1} + P_2 \ln \frac{P_2}{Q_2}
$$

### [직관적 의미]

여러 개의 미세한 사건들을 $2$개의 큰 덩어리로 뭉뚱그려(Coarse-graining) 관찰할 경우, 분포 간의 구별 가능성(정보량)이 줄어들기 때문에 발산 값이 감소한다.

예를 들어 주사위 $6$개 눈 각각의 발생 확률로 두 주사위를 구별하는 것보다, 단순히 "3 이상인가 3 미만인가"로 뭉뚱그려 구별하려고 하면 차이를 식별하기 훨씬 어려워지는 것과 완벽히 같은 이치이다.

---

## 2.2 부등식의 확장 (테일러 급수 전개)

임의의 사건 $A$에 대해 두 확률의 차이를 $\delta$라 정의하자:

$$
x = \delta(P, Q) = P(A) - Q(A) = P_1 - Q_1 \quad (P_1 \ge Q_1)
$$

여기서 $Q_1, Q_2$를 고정하고 차이 $x$를 변수로 취급하면, $P_1$과 $P_2$는 다음과 같이 표현된다:

$$
P_1 = Q_1 + x, \quad P_2 = Q_2 - x
$$

이제 $x$에 대한 보조 함수 $g(x)$를 다음과 같이 정의하자:

$$
g(x) = P_1 \ln \frac{P_1}{Q_1} + P_2 \ln \frac{P_2}{Q_2} = (Q_1 + x) \ln \frac{Q_1 + x}{Q_1} + (Q_2 - x) \ln \frac{Q_2 - x}{Q_2}
$$

함수 $g(x)$를 $x$에 대해 $1$차 및 $2$차 미분해보면:

$$
g'(x) = \left( \ln \frac{Q_1 + x}{Q_1} + 1 \right) - \left( \ln \frac{Q_2 - x}{Q_2} + 1 \right) = \ln \frac{Q_1 + x}{Q_1} - \ln \frac{Q_2 - x}{Q_2}
$$
$$
g''(x) = \frac{1}{Q_1 + x} + \frac{1}{Q_2 - x} = \frac{1}{P_1} + \frac{1}{P_2}
$$

이때 $P_1 + P_2 = 1$이고 둘 다 양수이므로, 코시-슈바르츠 부등식(또는 산술-조화평균 부등식)에 의해 $g''(x)$의 하한을 구할 수 있다:

$$
(P_1 + P_2) \left(\frac{1}{P_1} + \frac{1}{P_2}\right) \ge (1 + 1)^2 = 4 \implies g''(x) = \frac{1}{P_1} + \frac{1}{P_2} \ge 4
$$

이제 함수 $g(x)$에 대해 $x=0$을 중심으로 **$2$차 테일러 급수와 라그랑주 나머지 항 정리**를 적용한다:

$$
g(x) = g(0) + g'(0) x + \frac{g''(c)}{2} x^2 \quad (0 < c < x)
$$

여기서 $g(0) = 0$, $g'(0) = 0$이므로 일차항까지는 모두 소거된다:

$$
g(0) = Q_1 \ln 1 + Q_2 \ln 1 = 0
$$
$$
g'(0) = \ln 1 - \ln 1 = 0
$$

따라서 함수 $g(x)$는 나머지 항만 남게 되며, $g''(c) \ge 4$를 대입하면 다음 부등식을 얻는다:

$$
g(x) = \frac{g''(c)}{2} x^2 \ge \frac{4}{2} x^2 = 2x^2 = 2 \delta(P, Q)^2
$$

2.1절의 결과와 종합하면 다음 관계가 성립한다:

$$
D_{KL}(P \parallel Q) \ge g(x) \ge 2\delta(P, Q)^2 = 2 \left(P(A) - Q(A)\right)^2
$$

---

## 3. 최종 결론

위 부등식은 **임의의 사건 집합 $A$에 대해 모두 성립**한다.

전변차 거리(Total Variation Distance)의 정의는 모든 사건 $A$에 대한 확률 차이의 최댓값(Supremum)이므로:

$$
D_{TV}(P, Q) = \max_A |P(A) - Q(A)|
$$

부등식의 우변에 최댓값을 취해주면:

$$
D_{KL}(P \parallel Q) \ge 2 \max_A \left(P(A) - Q(A)\right)^2 = 2 D_{TV}(P, Q)^2
$$

양변을 $2$로 나누고 제곱근을 취하면 최종적으로 **핀스커 부등식(Pinsker's Inequality)**이 완성된다:

$$
D_{TV}(P, Q) \le \sqrt{\frac{1}{2} D_{KL}(P \parallel Q)}
$$
