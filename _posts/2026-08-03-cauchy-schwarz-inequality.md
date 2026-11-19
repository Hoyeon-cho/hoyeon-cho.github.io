---
title: "코시-슈바르츠 부등식 증명"
date: 2026-08-03 10:41:16 +0900
categories: ["수학 및 알고리즘"]
tags: ["부등식"]
description: "내적과 코사인을 이용해 코시-슈바르츠 부등식을 증명한다."
math: true
---
벡터 정의

$$
\vec{a}=\left(a_1\ a_2\ \cdots \ a_n\ \right),\ \vec{b}=\left(b_1\ b_2\ \cdots \ b_n\ \right)
$$

내적은 다음과 같다

$$
\vec{a}\cdot \vec{b}=\|\vec{a}\|\cdot \|\vec{b}\|\cdot \cos \left(\theta \right)
$$

코사인 함수의 절댓값은 1 이하이므로 ($|\cos(\theta)| \le 1$) 다음이 성립한다.

$$
|\vec{a} \cdot \vec{b}|\le \|\vec{a}\|\cdot \|\vec{b}\|
$$

각 요소는 다음과 같이 정의된다

$$
\vec{a}\cdot \vec{b}=\sum a_ib_i
$$
$$
\|\vec{a}\|=\sqrt{\sum a_i^2}
$$
$$
\|\vec{b}\|=\sqrt{\sum b_i^2}
$$

대입해서 정리하면 마무리된다

$$
\left(\sum a_ib_i\right)^2\le \left(\sum a_i^2\right)\cdot \left(\sum b_i^2\right)
$$
