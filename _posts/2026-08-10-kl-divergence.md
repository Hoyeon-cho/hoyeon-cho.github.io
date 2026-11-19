---
title: "KL Divergence"
date: 2026-08-10 14:45:53 +0900
categories: ["수학 및 알고리즘"]
tags: ["확률 분포 거리", "정보 이론"]
description: "정보량과 엔트로피, 크로스 엔트로피에서 출발해 KL Divergence의 의미를 정리한다."
math: true
---
## 1. 정보량과 엔트로피

정보 이론에서 정보량은 다음과 같이 정의된다

$$
I\left(x\right)=-\log _2p\left(x\right)
$$

확률이 p(x)인 정보의 최소(또는 최적)크기를 나타내고, 단위는 bit이다. 확률이 작을수록 놀라운(또는 희귀한)정보이기 때문에 이를 표현하기 위해선 큰 bit가 필요하다고 이해할 수 있다.( 아래 예시와 함께 자세히 설명 )

log_2를 안쓰고 자연로그 ln을 많이 쓰기도 하는데, 이는 수학적 편리를 위함으로 보인다. 스케일의 차이니 큰 문제는 없다

이어서 엔트로피는 다음과 같이 정의된다.

$$
H\left(P\right)=-\sum _x^{\mathbf{\ }}p\left(x\right)\log _2p\left(x\right)
$$

이는 두가지 의미로 해석될 수 있다: 첫째로 어떤 확률 분포의 평균 정보량 ( 확률 * 정보량의 합)

두번째로는 해당 정보 집합을 최적으로 전송했을 시 발생하는 평균 정보량(bit)이다.

이해를 위해 다음과 같은 예시를 들어보자

카운터 종업원은 주문을 받아 요리사에게 전달하는 상황을 생각해보자.

이들은 다년간의 장사로 정확한 주문량 분포를 알고있다고 하자.

매번 말로 전달하려니 잘 들리지도 않고 입도 아프고 그래서 다음과 같이 비트 형식으로 전달하고자 시도한다.

그러면, 각 메뉴를 어떻게 표현하는것이 가장 최적일까? 일단 단순하게 메뉴가 4개니까 다음과 같이 표현할 수 있다.

* 돼지국밥: `00₂`
* 순대국밥: `01₂`
* 제육: `10₂`
* 소주: `11₂`

이런 경우 주문 당 평균 정보량은 2bit이다. 이를 좀 더 효율적으로 만들 수 없을까?

이를테면, 주문량이 많은 돼지국밥은 정보량을 좀 줄이고, 주문량이 적은 메뉴들은 정보량을 좀 늘리면 전체 평균 정보량이 줄지 않을까? 이를 위해 다음과 같이 수정해본다.

* **돼지국밥**: `0₂` (비트 크기: $-\log_2 p(\text{돼지국밥}) = 1$)
* **순대국밥**: `10₂` (비트 크기: $-\log_2 p(\text{순대국밥}) = 2$)
* **제육**: `110₂` (비트 크기: $-\log_2 p(\text{제육}) = 3$)
* **소주**: `111₂` (비트 크기: $-\log_2 p(\text{소주}) = 3$)

이전에는 메뉴 당 무조건 2bit로, 들어오는 정보를 그냥 두칸씩 끊어 읽으면 됐지만, 이번 경우는 메뉴마다 정보량이 다르기 때문에 문자를 해독할 방법이 필요하다. 다음과 같은 방법으로 해독을 진행한다.

```python
b = next(bit)
if b == 0:
    menu = "돼지국밥"
else:
    b = next(bit)
    if b == 0:
        menu = "순대국밥"
    else:
        b = next(bit)
        if b == 0:
            menu = "제육"
        else:
            menu = "소주"
```

이런식으로 진행했을 경우, 다음과 같이 요리사가 정보를 읽게 된다.

평균 정보량은 다음과 같이 계산된다.

$$
E\left[I\right]=H\left(P\right)=-\sum _x^{\mathbf{\ }}\left[p\left(x\right)\cdot \log _2p\left(x\right)\right]=1.75\ bit
$$

이전 방식보다 0.25bit가 줄었다. 우리는 해당 방식이 최선임을 감각적으로는 알지만, 수학적으로는 모른다. 이를 증명할 필요가 있다.

## 2. 크로스 엔트로피

크로스 엔트로피 식은 다음과 같다

$$
H\left(P,\ Q\right)=-\sum _xp\left(x\right)\cdot \log _2\left(q\left(x\right)\right)
$$

해당 식을 다음과 같이 설명할 수 있다: 확률분포 p를 따르는 정보를 확률분포가 q를 따른다고 착각했을 시 발생하는 평균 정보량.

다음과 같은 상황을 생각해보자

실제 주문은 분포p를 따라 들어오지만, 카운터와 요리사는 분포q를 따른다고 착각하고 이전과 같이 메뉴를 비트로 정리한다고 하자. 그러면 평균 사용 정보량은 크로스 엔트로피와 동일해진다.

여기서 알 수 있는것은, 분포를 정확히 알 때 보다 더 큰 정보량이 든다는것이다. 이를 식으로 표현하면 다음과 같다.

$$
H\left(P\right)\le H\left(P,\ Q\right)
$$

증명 --------------------

$$
H\left(P,\ Q\right)-H\left(P\right)=-\sum _xp\left(x\right)\log \left(\frac{q\left(x\right)}{p\left(x\right)}\right)
$$
$$
\ge -\sum _xp\left(x\right)\cdot \left(\frac{q\left(x\right)}{p\left(x\right)}-1\right)\ \ \ \ \ \ \ \left(\because \ln \left(t\right)\le t-1\right)
$$
$$
=-\sum _x\left[q\left(x\right)-p\left(x\right)\right]=0
$$
$$
\therefore \ H\left(P\right)\le H\left(P,\ Q\right)
$$

log2를 ln으로 대체한것은 수학적 편리 때문이다. 결과는 달라질것이 없다.

--------------------

## 3. KL Divergence

이제 마지막 KL Divergence에 대해서 이야기하고자 한다. 식은 다음과 같다.

$$
D_{KL}\left(P\right|\left|Q\right)=\sum _xp\left(x\right)\log _2\left(\frac{p\left(x\right)}{q\left(x\right)}\right)=H\left(P,\ Q\right)-H\left(P\right)\left(\ge 0\right)
$$

0보다 왜 큰지는 앞부분의 증명을 참고하자.

해당 식은 두가지 의미로 해석될 수 있다.

두 확률분포의 차이(비대칭)

확률 분포P를 Q로 착각했을 때 발생되는 손해 정보량

2번의 경우 앞서 진행된 예시로서 설명이 되었다.
