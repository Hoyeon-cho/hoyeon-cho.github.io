---
title: "테일러 급수와 나머지 항 정리"
date: 2026-08-11 20:31:53 +0900
categories: ["수학 및 알고리즘"]
tags: ["테일러 급수"]
description: "테일러 급수 전개와 나머지 항, 라그랑주 나머지 형태를 유도한다."
math: true
---
## 1. 테일러 급수

임의의 함수는 어떤 점 $a$에 대해 다음과 같은 급수 형태로 정리된다.

$$
f\left(x\right)=f\left(a\right)+f'\left(a\right)\left(x-a\right)+\frac{f''\left(a\right)}{2!}\left(x-a\right)^2+\frac{f^{\left(3\right)}\left(a\right)}{3!}\left(x-a\right)^3+\cdots
$$
$$
=\sum _{n=0}^{\infty}\left[\frac{f^{\left(n\right)}\left(a\right)}{n!}\left(x-a\right)^n\right]
$$

여기서 주목할 점은 항이 뒤로 갈수록 팩토리얼 스케일로 계수가 작아진다는 것이다.

이 말인 즉슨, 뒤에 있는 항일수록 소거해도 원래 함수와 큰 차이 없이 근사화할 수 있다는 것이다.

그렇다면 얼마나 뒤쪽을 자르는 게 합리적일까?

이를 알기 위해서 다음과 같이 식을 다시 작성해본다.

$$
f\left(x\right)=\sum _{n=0}^k\left[\frac{f^{\left(n\right)}\left(a\right)}{n!}\left(x-a\right)^n\right]+\sum _{n=k+1}^{\infty}\left[\frac{f^{\left(n\right)}\left(a\right)}{n!}\left(x-a\right)^n\right]
$$
$$
=P_k\left(x\right)+R_k\left(x\right)
$$

테일러 급수의 중간을 딱 잘라서 근사화 부분($P_k$)과 나머지 부분($R_k$)으로 나누어 정리하였다.

만약 $R_k$의 식을 알 수 있다면, 우리가 사용하고자 하는 영역에 대해 어디까지 급수를 자르는 것이 적절한지 판단할 수 있지 않을까?

## 2. 나머지 항 구하기

나머지 항 $R_k$를 구하기 위해 테일러 급수를 적분 형태로 풀어가보아야 한다.

먼저 미적분학의 기본정리에 따라 다음과 같이 식을 적어본다.

$$
f\left(x\right)=f\left(a\right)+\int _a^xf'\left(t\right)\ dt
$$

다음으로 부분적분법을 활용해 적분항을 다시 정리해준다.

$$
f\left(x\right)=f\left(a\right)+\int _a^xf'\left(t\right)\ dt
$$
$$
=f\left(a\right)+\left[-f'\left(t\right)\left(x-t\right)\right]_a^x-\int _a^x-f''\left(t\right)\left(x-t\right)\ dt
$$
$$
=f\left(a\right)+f'\left(a\right)\left(x-a\right)+\int _a^xf''\left(t\right)\left(x-t\right)\ dt
$$

이 과정을 한 번만 더 해보자.

$$
=f\left(a\right)+f'\left(a\right)\left(x-a\right)+\int _a^xf''\left(t\right)\left(x-t\right)\ dt
$$
$$
=f\left(a\right)+f'\left(a\right)\left(x-a\right)-\left[-\frac{f''\left(t\right)}{2!}\left(x-t\right)^2\right]_a^x-\int _a^x-\frac{f^{\left(3\right)}\left(t\right)}{2!}\left(x-t\right)^2\ dt
$$
$$
=f\left(a\right)+f'\left(a\right)\left(x-a\right)+\frac{f''\left(a\right)}{2!}\left(x-a\right)^2+\int _a^x\frac{f^{\left(3\right)}\left(t\right)}{2!}\left(x-t\right)^2\ dt
$$

이쯤 되면 규칙성이 확인된다. 이를 $k$번 진행하면 다음과 같이 항이 정리된다.

$$
f\left(x\right)=\sum _{n=0}^k\left[\frac{f^{\left(n\right)}\left(a\right)}{n!}\left(x-a\right)^n\right]+\int _a^x\frac{f^{\left(k+1\right)}\left(t\right)}{k!}\left(x-t\right)^k\ dt
$$
$$
R_k\left(x\right)=\int _a^x\frac{f^{\left(k+1\right)}\left(t\right)}{k!}\left(x-t\right)^k\ dt
$$

나머지 항이 적분 텀으로 깔끔하게 정리되었다.

## 3. 라그랑주 나머지

적분항은 실제 계산하기 어려울 수 있다. 또는 굳이 정확한 값을 모르고 대략적인 상한/하한 값만 알아도 충분한 경우들이 있다. 그래서 한 번 더 정리를 진행한다.

적분의 평균값 정리는 다음과 같다.

$$
\int _a^xg\left(t\right)h\left(t\right)\ dt=g\left(c\right)\int _a^xh\left(t\right)\ dt,\ \ \ \ c\in \left[a,\ x\right]
$$

이를 나머지 항에 적용한다.

$$
R_k\left(x\right)=\int _a^x\frac{f^{\left(k+1\right)}\left(t\right)}{k!}\left(x-t\right)^k\ dt=f^{\left(k+1\right)}\left(c\right)\int _a^x\frac{\left(x-t\right)^k}{k!}\ dt
$$
$$
=f^{\left(k+1\right)}\left(c\right)\left[-\frac{\left(x-t\right)^{k+1}}{\left(k+1\right)!}\right]_a^x=f^{\left(k+1\right)}\left(c\right)\frac{\left(x-a\right)^{k+1}}{\left(k+1\right)!}
$$

마지막으로 테일러 급수를 다시 정리해본다.

$$
f\left(x\right)=P_k\left(x\right)+R_k\left(x\right)
$$
$$
=\sum _{n=0}^k\left[\frac{f^{\left(n\right)}\left(a\right)}{n!}\left(x-a\right)^n\right]+f^{\left(k+1\right)}\left(c\right)\frac{\left(x-a\right)^{k+1}}{\left(k+1\right)!}
$$

우리는 $c$가 정확히 어떤 값인지는 모른다. 하지만 어떤 유계된 영역이 주어졌을 때 수치적으로 근사값과 최대 오차를 충분히 계산할 수 있다.

추가: 적분의 평균값 정리(가중 적분 평균값 정리)를 적용하려면 구간 내에서 가중치 함수 $h(t) = \frac{(x-t)^k}{k!}$의 부호가 바뀌지 않아야 한다. $t$가 $a$와 $x$ 사이에 있을 때 $(x-t)^k$는 부호가 일정하므로 이 정리가 완벽하게 성립한다.
