---
title: "Total Variation Distance"
date: 2026-08-06 20:32:00 +0900
categories: ["수학 및 알고리즘"]
tags: ["확률 분포 거리"]
description: "두 확률 분포의 차이를 직관적으로 보여주는 Total Variation Distance의 정의와 성질을 정리한다."
math: true
---
## 1. 정의

두 확률 분포가 어떻게 다른지를 정말 직관적으로 보여주는 식이다.

$$
D_{TV}\left(p,q\right)=\frac{1}{2}\sum _{x\in X}\left|p\left(x\right)-q\left(x\right)\right|
$$

## 2. 성질

어떤 사건(부분집합) $A$에 대해 다음과 같은 공식이 성립한다.

$$
\max _{A\subset X}\left|p\left(A\right)-q\left(A\right)\right|=D_{TV}\left(p,q\right)\left(=\frac{1}{2}\sum _{x\in X}\left|p\left(x\right)-q\left(x\right)\right|\right)
$$

사건 $A$는 하나의 결과만 포함하는 근원사건일 수도 있고, 여러 결과의 집합(예: 주사위 눈이 1 또는 2가 나오는 사건 $A=\{1, 2\}$)일 수도 있다.

어떻게 사건 $A$를 조합하든 그 차이가 최대가 되는 값과 같다는 것이다.

증명 --------------------

먼저, 너무 당연한 식 하나를 쓴다.

$$
\sum p\left(x\right)-\sum q\left(x\right)=1-1=0
$$

여기서 사건 집합 $X$를 두 가지 경우로 나눈다.

$$
X^+ = \{ x \in X \mid p(x) \ge q(x) \}
$$
$$
X^- = X \setminus X^+ = \{ x \in X \mid p(x) \lt q(x) \}
$$

즉, $X^+$ 영역에서는 $p(x) - q(x) \ge 0$의 값을 가지는 것이다.

이를 위의 식에 대입한다.

$$
\sum p\left(x\right)-\sum q\left(x\right)=\sum _{x\in X^+}\left[p\left(x\right)-q\left(x\right)\right]+\sum _{x\in X^-}\left[p\left(x\right)-q\left(x\right)\right]=0
$$
$$
\overbrace{\sum _{x\in X^+}\left[p\left(x\right)-q\left(x\right)\right]}^{=S}=-\sum _{x\in X^-}\left[p\left(x\right)-q\left(x\right)\right]
$$

이 식에서 말하는 바는 다음과 같다: $p$가 더 큰 영역에서의 차이의 합과 $q$가 더 큰 영역에서의 차이의 합(절댓값)은 동일하다 ($S = -(-S)$).

$D_{TV}$에 이를 적용해본다.

$$
D_{TV}\left(p,q\right)=\frac{1}{2}\sum _{x\in X}\left|p\left(x\right)-q\left(x\right)\right|=\frac{1}{2}\left(\sum _{x\in X^+}\left[p\left(x\right)-q\left(x\right)\right]+\sum _{x\in X^-}\left[q\left(x\right)-p\left(x\right)\right]\right)
$$
$$
=\frac{1}{2}\left(S-\left(-S\right)\right)=S
$$

$D_{TV}$가 어떤 실수 $S$와 같다는 것이 증명되었다. 이제 $S$가 우리가 증명하고자 하는 개념과 이어지기만 하면 된다.

이해를 위해 새로운 표본 집합 $X''$를 정의한다.

* $X''$: $X^+$에 $X^-$의 원소 중 임의의 몇 개가 추가된 집합

그러면 다음과 같은 식이 유도된다.

$$
S''=\sum _{x\in X''}\left[p\left(x\right)-q\left(x\right)\right]=\sum _{x\in X^+}\left[p\left(x\right)-q\left(x\right)\right]+\overbrace{\sum _{x\in \left(X''-X^+\right)}\left[p\left(x\right)-q\left(x\right)\right]}^{\lt 0}\lt S
$$

추가로, $X^+$ 집합 중 몇 개가 빠진 경우도 고려해야 하는데 비슷한 방법으로 증명되니 생략하겠다.

즉, $p$가 $q$보다 큰 모든 사건(표본)을 포함하는 사건 집합이 두 확률의 차이($=S$)가 가장 큰 경우가 된다.

당연히 그 역도 가능하다.

--------------------

이어서 다음과 같은 성질도 가진다.

두 커플링된 확률분포에서 각각 $x, y$를 샘플링할 때,

$$
\max _{\gamma }\ P_{\gamma }\left(X=Y\right)=\sum \min \left(p\left(x\right),q\left(x\right)\right)=1-D_{TV}\left(p,q\right)
$$

가 성립한다.

이때 커플링이라는 것은 한 개의 공통된 변수로부터 두 표본에서 샘플링을 진행한다는 것이다.

예를 들어, (확률의 총합은 1이니) 0부터 1까지 이루어진 띠가 두 줄 있고, 이 위에 각각 자유롭게 확률을 배치시킨다고 하자. 하나의 사건이어도 띄엄띄엄 배치시킬 수 있는 것이다.

그리고 rand()를 진행해 나온 숫자로부터 각각 표본을 샘플링하는 상황을 생각해보자.

$X = Y$인 영역이 최대가 되게 하려면 어떻게 해야 할까? 각 표본에 대해 $p(x) = q(x)$가 최대가 되도록 일단 배치하고, 찌꺼기들을 후방에 배치하면 된다. 이것이 위 식에서 말하는 바이다.

예시를 한번 들어보자.

$$
p\left(x\right)=\left[0.2,\ 0.4,\ 0.4\right]
$$
$$
q\left(x\right)=\left[0.3,\ 0.3,\ 0.4\right]
$$

첫 번째 표본에 대해서 $p(x)$가 $0.2$이기 때문에, 첫 번째 표본이 같을 확률은 $0.2$를 넘길 수가 없는 것이다.

따라서 커플링된 상황에서 두 표본이 같을 확률의 최댓값은 $0.2 + 0.3 + 0.4 = 0.9$이다.

그렇다면 왜 $(1 - D_{TV})$인가에 대해서도 이야기해야 한다.

$D_{TV}$의 sum 안쪽 항을 다음과 같이 쓸 수 있다.

$$
\left|p\left(x\right)-q\left(x\right)\right|=\left(p\left(x\right)-\min \left(p\left(x\right),q\left(x\right)\right)\right)+\left(q\left(x\right)-\min \left(p\left(x\right),q\left(x\right)\right)\right)
$$

우변 항에 대해 설명을 덧붙이자면, 첫 번째 항 또는 두 번째 항 둘 중 하나는 $0$이다.

양변에 sum을 취해준 다음 정리하면 증명은 완료된다.

$$
\sum _x\left|p\left(x\right)-q\left(x\right)\right|=\sum _x\left[\left(p\left(x\right)-\min \left(p\left(x\right),q\left(x\right)\right)\right)+\left(q\left(x\right)-\min \left(p\left(x\right),q\left(x\right)\right)\right)\right]
$$
$$
=\sum _x\left(p\left(x\right)+q\left(x\right)\right)-2\sum _x\min \left(p\left(x\right),q\left(x\right)\right)=2\left(1-\sum _x\min \left(p\left(x\right),q\left(x\right)\right)\right)
$$
$$
\therefore D_{TV}\left(p,q\right)=\frac{1}{2}\sum _{x\in X}\left|p\left(x\right)-q\left(x\right)\right|=1-\sum _x\min \left(p\left(x\right),q\left(x\right)\right)
$$
$$
\max _{\gamma }\ P_{\gamma }\left(X=Y\right)=\sum _x\min \left(p\left(x\right),q\left(x\right)\right)=1-D_{TV}\left(p,q\right)
$$
