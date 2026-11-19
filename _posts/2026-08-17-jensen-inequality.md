---
title: "젠센(옌센) 부등식"
date: 2026-08-17 15:53:22 +0900
categories: ["수학 및 알고리즘"]
tags: ["부등식"]
description: "볼록 함수에서 성립하는 젠센 부등식을 두 점인 경우와 수학적 귀납법으로 증명한다."
math: true
---
## 1. 정의

어떤 함수 $f$가 (적용되는 구간에서) 볼록(Convex)하다면, 다음 부등식을 항상 만족한다.

$$
f\left(\sum_{i=1}^n \lambda_i x_i\right) \le \sum_{i=1}^n \lambda_i f(x_i), \quad \sum_{i=1}^n \lambda_i = 1, \quad \lambda_i \ge 0
$$

이를 평균값 기호($\overline{x}$) 또는 기댓값 기호($\mathbb{E}$)를 사용해 직관적으로 표현하면 다음과 같다:

$$
f\left(\overline{x}\right) \le \overline{f(x)}
$$
$$
f(\mathbb{E}[X]) \le \mathbb{E}[f(X)]
$$

이 식이 말하는 바는 다음과 같다: **"함숫값들의 평균(우변)은, 평균의 함숫값(좌변)보다 항상 크거나 같다."**

## 2.1 증명: $n = 2$인 경우

두 점에 대한 젠센 부등식은 볼록 함수(Convex Function)의 수학적 정의 그 자체이다.

$$
f(\lambda x_1 + (1-\lambda)x_2) \le \lambda f(x_1) + (1-\lambda)f(x_2), \quad 0 \le \lambda \le 1
$$

기하학적으로 볼 때, 함수 곡선 위의 두 점 $(x_1, f(x_1))$과 $(x_2, f(x_2))$를 잇는 할선(선분)은 항상 볼록 함수 곡선보다 위쪽에 위치하므로 자명하게 성립한다.

## 2.2 증명: $n > 2$인 경우 (수학적 귀납법)

$k$개의 데이터에 대해 부등식이 성립한다고 가정하자:

$$
f\left(\sum_{i=1}^k \lambda_i x_i\right) \le \sum_{i=1}^k \lambda_i f(x_i), \quad \sum_{i=1}^k \lambda_i = 1, \quad \lambda_i \ge 0
$$
$$
f\left(\overline{x}_k\right) \le \overline{f(x)}_k
$$

$k$개의 데이터에 대한 결과지만, 이제부터 이것을 새로운 하나의 가상 데이터(질량 중심 $\overline{x}_k$)로 취급해보자.

이때 $k+1$번째 데이터가 새로 들어오고, 가중치의 재조정이 발생한다고 하자:

$$
\overline{x}_{k+1} = \alpha_k \overline{x}_k + \alpha_{k+1} x_{k+1}, \quad \alpha_k + \alpha_{k+1} = 1
$$

즉, 점의 개수가 $k+1$개인 복잡한 문제를 이미 증명된 '$2$개의 점' 문제로 축소한 것이다.

이렇게 취급해도 상관없는 이유는, 모든 $i=1, \dots, k$에 대해 원래 가중치를 다음과 같이 가역적으로 분해할 수 있기 때문이다:

$$
\lambda_i \gets \alpha_k \lambda_i \quad (i = 1, \dots, k), \quad \lambda_{k+1} = \alpha_{k+1}
$$

이제 전체 식을 전개해보면 다음과 같다:

$$
\overline{f(x)}_{k+1} = \alpha_k \overline{f(x)}_k + \alpha_{k+1} f(x_{k+1})
$$
$$
\ge \alpha_k f(\overline{x}_k) + \alpha_{k+1} f(x_{k+1})
$$
$$
\ge f(\alpha_k \overline{x}_k + \alpha_{k+1} x_{k+1}) = f(\overline{x}_{k+1})
$$
$$
\therefore f\left(\overline{x}_{k+1}\right) \le \overline{f(x)}_{k+1}
$$

다시 리마인드하자면, $\overline{x}_k$와 $x_{k+1}$이라는 두 점에 대해 2.1절에서 증명한 $n=2$ 부등식을 적용한 것이다.

결과적으로 $n=2$에서 성립함을 보였고, 수학적 귀납법에 의해 모든 자연수 $n$에 대해 부등식이 성립함이 증명되었다.

추가적으로, 함수가 오목(Concave)하다면 부등호 방향이 반대로 뒤집히며, 함수가 완전한 직선(Linear)일 때 등호가 성립한다.
