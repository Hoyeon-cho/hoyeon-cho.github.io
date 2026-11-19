---
title: "로그합 부등식"
date: 2026-08-28 12:22:40 +0900
categories: ["수학 및 알고리즘"]
tags: ["부등식"]
description: "젠센 부등식을 이용해 로그합 부등식을 증명한다."
math: true
---
👉 선행 개념: [젠센(옌센) 부등식](/posts/jensen-inequality/)

## 1. 정의

음이 아닌 실수 $a_1, \dots, a_n$과 $b_1, \dots, b_n$에 대해 다음 부등식이 항상 성립한다:

$$
\sum_{i=1}^n a_i \ln \frac{a_i}{b_i} \ge \left(\sum_{i=1}^n a_i\right) \ln \frac{\sum_{i=1}^n a_i}{\sum_{i=1}^n b_i}
$$

(단, $a_i = 0$인 경우 $0 \ln 0 = 0$, $b_i = 0$인 경우 $a_i = 0$으로 취급한다.)

## 2. 증명

젠센 부등식(Jensen's Inequality)에 따르면, 볼록 함수 $f$와 합이 $1$인 가중치 $\lambda_i \ge 0$에 대해 다음이 성립한다:

$$
\sum_{i=1}^n \lambda_i f(x_i) \ge f\left(\sum_{i=1}^n \lambda_i x_i\right)
$$

여기서 함수 $f(x)$를 다음과 같이 정의하자:

$$
f(x) = x \ln x \quad (x > 0)
$$

이 함수의 $2$계 도함수를 구해보면 다음과 같다:

$$
f'(x) = \ln x + 1, \quad f''(x) = \frac{1}{x} > 0
$$

$x > 0$인 모든 영역에서 $f''(x) > 0$이므로, 함수 $f(x)$는 엄격한 볼록(Strictly Convex) 함수이다.

이제 젠센 부등식을 적용하기 위해 변수들을 다음과 같이 설정한다:

$$
B = \sum_{i=1}^n b_i
$$
$$
\lambda_i = \frac{b_i}{B} \quad \left(\sum_{i=1}^n \lambda_i = 1\right)
$$
$$
x_i = \frac{a_i}{b_i}
$$

위 설정들을 젠센 부등식의 좌변과 우변에 각각 대입해본다.

### 1) 좌변 전개

$$
\sum_{i=1}^n \lambda_i f(x_i) = \sum_{i=1}^n \frac{b_i}{B} \left(\frac{a_i}{b_i} \ln \frac{a_i}{b_i}\right) = \frac{1}{B} \sum_{i=1}^n a_i \ln \frac{a_i}{b_i}
$$

### 2) 우변 전개

먼저 가중합 $\sum \lambda_i x_i$를 정리한다:

$$
\sum_{i=1}^n \lambda_i x_i = \sum_{i=1}^n \frac{b_i}{B} \frac{a_i}{b_i} = \frac{1}{B} \sum_{i=1}^n a_i = \frac{\sum a_i}{\sum b_i}
$$

이를 함수 $f(x) = x \ln x$에 대입하면 다음과 같다:

$$
f\left(\sum_{i=1}^n \lambda_i x_i\right) = \left(\frac{\sum a_i}{B}\right) \ln \left(\frac{\sum a_i}{\sum b_i}\right)
$$

### 3) 젠센 부등식 적용 및 양변 정리

좌변과 우변의 결과를 젠센 부등식에 대입한다:

$$
\frac{1}{B} \sum_{i=1}^n a_i \ln \frac{a_i}{b_i} \ge \left(\frac{\sum a_i}{B}\right) \ln \frac{\sum a_i}{\sum b_i}
$$

양변에 양수 $B = \sum b_i$를 곱하여 정리하면 로그합 부등식이 완성된다:

$$
\therefore \sum_{i=1}^n a_i \ln \frac{a_i}{b_i} \ge \left(\sum_{i=1}^n a_i\right) \ln \frac{\sum_{i=1}^n a_i}{\sum_{i=1}^n b_i}
$$
