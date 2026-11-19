---
title: "확률 밀도 함수와 로그 밀도 함수(연속 행동 공간)"
date: 2026-10-10 17:26:33 +0900
categories: ["수학 및 알고리즘"]
tags: ["확률 밀도", "연속 행동 공간"]
description: "연속 행동 공간에서 가우시안 정책의 확률 밀도와 로그 밀도, tanh squashing에 따른 보정을 정리한다."
math: true
---
## 0. 서론

강화학습에서 정책 신경망은 다음과 같은 입력-출력 구조로 이루어져 있다.

$$
\left[\text{상태 } s_t\right] \longrightarrow \left[\text{신경망 } \phi\right] \longrightarrow \left[\text{중간값 } \mu_i,\ \text{로그 표준편차 } \log \sigma_i\right]
$$

연속 행동 공간에 대해 행동은 가우시안 분포를 따르는 확률적인 값으로 취급된다.

학습 초기에는 분산이 크다가 학습이 진행됨에 따라 작아지고, 나중에 사용할 때는 분산 출력은 자르고 사용한다.

참고로 분산을 로그 표준편차로 뱉는 이유는 표준편차가 양수임을 보장하기 위함이다.

신경망을 통과한 값의 범위는 꽤나 뒤죽박죽이기 때문에 이를 한번 정제할 필요가 있다.

$$
u_i\sim \mathcal{N} \left(\mu _i,\ \sigma _i^2\right)
$$
$$
a_i=\tanh \left(u_i\right)
$$
$$
\left(\tanh \left(x\right)=\frac{e^x-e^{-x}}{e^x+e^{-x}}\in \left[-1,1\right]\right)
$$

출력된 중간값과 분산을 통해 어떤 방식으로 u값을 샘플링 한 후, 이를 -1에서 1의 값으로 Squashing 한다.

( 샘플링 방법은 알고리즘에 따라 다양한걸로 알고있다 )

이후 모터에 입력을 보낼 때 모터 출력 범위에 맞게 스케일링하여 진행한다.

이를 수학적으로 풀어나가는 과정에서 확률 밀도를 확률인것처럼 사용함에 의문을 가져 공부하게 되었다.

수식에 하첨자 i를 계속 사용하는 이유는 행동 차원 D 중 하나임을 암시하기 위함이다.

( 예시: 4족 보행 로봇의 행동 차원은 12이다 )

## 2. 확률 밀도 함수와 확률

가우시안 분포를 따르는 확률 밀도 함수는 다음과 같이 정의된다.

$$
p_{U,\ i}\left(u\right)=\frac{1}{\sqrt{2\pi }\sigma _i}\exp \left(-\frac{\left(\mu _i-u\right)^2}{2\sigma _i^2}\right)
$$
$$
\int _{-\infty }^{\infty}p_{U,\ i}\left(u\right)\ du=1
$$

확률 밀도 함수로부터 확률을 계산하는 식은 다음과 같다.

$$
P_{U,\ i}\left(u_1\le U\le u_2\right)=\int _{u_1}^{u_2}p_i\left(u\right)\ du
$$

그렇다면, 특정값이 샘플링될 확률은 어떻게 표현될까?

아래와 같이 미소값으로 표현되고 그 값은 (굳이 따지면) 0이다.

$$
P_{U,\ i}\left(U=u_i\right)=P_{U,\ i}\left(u_i\le U\le u_i+du\right)=p_{U,\ i}\left(u_i\right)du\left(=0\right)
$$

근데 이상하다. 강화학습에서 정책은 특정 행동을 할 확률로부터 학습을 진행한다.

모든 특정 행동에 대한 확률은 0이지만, 그 기울기는 각기 다르다.

특정 확률이 아닌 확률의 기울기를 사용하여 학습을 진행하게 된다.

## 3. 확률 밀도 함수

이를 해결하기 위해 로그 밀도 함수를 도입한다.

로그 밀도 함수는 확률 밀도 함수에 로그를 취한 값으로 표현된다.

$$
\log \left(p_{U,\ i}\left(u\right)\right)=-\left(\frac{1}{2}\log 2\pi +\log \sigma _i+\frac{\left(\mu _i-u\right)^2}{2\sigma _i^2}\right)
$$

이를 확률에 적용하여 표현하면 다음과 같다.

$$
\log \left(p_{U,\ i}\left(u_i\right)du\right)=-\left(\frac{1}{2}\log 2\pi +\log \sigma _i+\frac{\left(\mu _i-u\right)^2}{2\sigma _i^2}\right)+\log du\left(=-\infty \right)
$$

로그 밀도 함수 뒤에 항이 하나 더 붙은 형태이다.

여기서 중요한 점은 뒤의 항은 상수라는것으로, 나중에 미분을 진행하면 소거되는 항이다.

## 4. Squashing

서론에서 언급한 바에 따르면, u값을 [-1,1]로 mapping 시켜야 한다.

해당 과정에서 중요한 점은, u값 하나 당 a값 하나로 1:1 대응된다는 것이다.

이는 즉 발생될 확률이 동일하다는 것과 같다.

이를 식으로 표현하면 다음과 같다.

$$
P_{A,\ i}\left(A=a_i\right)=P_{U,\ i}\left(U=u_i\right)
$$
$$
p_{A,\ i}\left(a_i\right)\left|\mathbf{da}\right|=p_{U,\ i}\left(u_i\right)\left|\mathbf{du}\right|
$$
$$
p_{A,\ i}\left(a_i\right)=\frac{p_{U,\ i}\left(u_i\right)}{\left|\frac{\mathbf{da}}{du}\right|}
$$
$$
\log p_{A,\ i}\left(a_i\right)=\log p_{U,\ i}\left(u_i\right)-\log \left|\frac{\mathbf{da}}{du}\right|
$$
$$
=-\left(\frac{1}{2}\log 2\pi +\log \sigma _i+\frac{\left(\mu _i-u\right)^2}{2\sigma _i^2}\right)+\log du-\log \left(1-a_i^2\right)
$$
$$
\left(\because (\tanh(x))' = 1 - \tanh^2(x) = 1 - y^2\right)
$$

## 5. 미분

pA는 에이전트가 특정 행동을 할 진짜 확률값이 되고, 이는 곧 정책과 같은 말이 된다.

다음과 같이 기울기가 정리된다.

$$
\pi_{\phi}\left(a_t|\ s_t\right)=p_{A,\ i}\left(a_t\right)
$$
$$
\log \pi _{\phi }\left(a_t|\ s_t\right)=-\left(\frac{1}{2}\log 2\pi +\log \sigma _i\left(\phi \right)+\frac{\left(\mu _i\left(\phi \right)-u_t\right)^2}{2\sigma _i^2\left(\phi \right)}\right)+\log du-\log \left(1-a_t^2\right)
$$
$$
\nabla _{\phi }\log \pi _{\phi }\left(a_t|\ s_t\right)=\nabla _{\phi }\left[-\left(\frac{1}{2}\log 2\pi +\log \sigma _i\left(\phi \right)+\frac{\left(\mu _i\left(\phi \right)-u_t\right)^2}{2\sigma _i^2\left(\phi \right)}\right)-\log \left(1-a_t^2\left(u_t\right)\right)\right]+\nabla _{\phi }\log du
$$
$$
=\nabla _{\phi }\left[-\left(0+\log \sigma _i\left(\phi \right)+\frac{\left(\mu _i\left(\phi \right)-u_t\right)^2}{2\sigma _i^2\left(\phi \right)}\right)-\log \left(1-a_t^2\left(u_t\right)\right)\right]+0
$$

미분 과정에서 자연스럽게 du가 소거된다.

이를 통해 확률 밀도 함수를 사용하는것이 곧 확률을 사용하는것과 같을 수 있음을 알 수 있다.

나머지 항 미분은 샘플링이 어떻게 진행되는가에 따라 달라질것이다.

## 6. 다차원 행동 공간에 대한 미분

각 행동이 독립시행이라고 가정한다면 어떤 상태에 대해 일련의 행동쌍이 발생할 확률은 다음과 같다.

$$
P_A\left(\hat{a}|\ s_t\right)=\prod _{i=1}^{D}\pi_{\phi}\left(a_i|\ s_t\right)=\pi _{\phi }\left(a_1|\ s_t\right)\pi _{\phi }\left(a_2|\ s_t\right)\cdots \pi_{\phi}\left(a_D|\ s_t\right)
$$

양변에 log를 씌우고 정리

$$
\log P_A\left(\hat{a}|\ s_t\right)=\log \pi _{\phi }\left(a_1|\ s_t\right)+\cdots + \log \pi_{\phi}\left(a_D|\ s_t\right)
$$
$$
=\sum _{i=1}^D\log p_{A,i}\left(a_i\right)+D\cdot \log da
$$

그냥 선형으로 더해지는 꼴이라 더 정리할 필요는 없는거같다.

미분값 또한 쭉 더해지는 꼴로 나타난다.

다만, "각 행동이 독립적일 때" 적용됨에 주의해야한다.

학습전 시스템의 각 행동이 독립적인지 체크하여 학습을 진행하여야 한다.

(보통 로봇은 독립적이라 상관이 없다)
