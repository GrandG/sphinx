# 牛宽科技面试题

```
一. 给定一个非空数组 A，含有 N 个整形数，下标以 0 开始。对数组 A 的一次交换操作是：
输入两个数组下标 I 和 J， 满足 0 ≤ I ≤ J <N， 交换 A[I] 和 A[J]的值。
目的是检查是否可以最多通过一次交换操作将数组 A 按非递减顺序排序。
举例：
例 1，数组 A 有如下元素：
A[0] = 1
A[1] = 5
A[2] = 3
A[3] = 3
A[4] = 7
对 A[1] 和 A[3]进行交换操作后我们得到的新数组[1, 3, 3, 5, 7]是按非递减顺序排序，故
可以通过一次交换操作达到目的。
例 2，数组 A 有如下元素：
A[0] = 1
A[1] = 3
A[2] = 5
A[3] = 3
A[4] = 4
无法最多仅通过一次交换操作使数组 A 变成非递减顺序。
例 3，数组 A 有如下元素：
A[0] = 1
A[1] = 3
A[2] = 5
数组 A 已经是按非递减顺序排序，可以通过 0 次交换操作达到目的。
要求：
1. 请用 Java 或 Python 语言写一个函数，接收一个整型数组参数 A，返回值为 bool 类
型，实现上述的对数组 A 的检查功能。在遇到类似例 1 和例 3 的情况时，函数应当
返回 true；遇到类似例 2 的情况时，返回 false。
2. 假定数组 A 含有 N 个元素， N 的取值范围是[1..100,000]，数组 A 的元素的取值范围
是[1..1,000,000,000]。
3. 复杂度：
期望最坏情况下的时间复杂度为 O(N*log(N))；
期望最坏情况下的空间复杂度为 O(N)，数组 A 本身的空间复杂度不计在内
```
<br>
<br>

<br>

<br>

<br>

答案: 
```python

def can_exchange_sort(array):
    count = 0
    sorted_array = sorted(array)
    for (x, y) in zip(array, sorted_array):
        if x != y:
            count += 1

    if count in (0, 2):
        return True
    return False
```

-------------



二. 答案

排列组合, 时间复杂度: O(n**2), 空间复杂度: O(1)
```python
def solution(array):
    count = 0
    i = 0
    length = len(array)
    while i < length:
        if count >= 1000000000:
            return -1
        if array[i] == 0:
            j = i + 1
            while j < length:
                if array[j] == 1:
                    count += 1
                j += 1
        i += 1
    return count
```
<br>
<br>
<br>
<br>

递归, 时间复杂度O(n**2), 空间复杂度: O(1)
```python
def solution_2(array):
    length = len(array)
    
    if length <= 1:
        return 0
    
    last_ele = array[-1]
    
    if last_ele == 0:
        count = solution_2(array[0: length-1])
    else:
        count = solution_2(array[0: length-1]) + array.count(0)
        
    return count
```

动态规划, 时间复杂度: O(n), 空间复杂度: O(n)
```python
def solution_3(array):
    a, idx, length = 0, 1, len(array)
    
    if length == 1:
        return 0
    
    zero_counter = 0 if array[0] else 1

    for ele in array[1:]:
        if ele == 1:
            b = a + zero_counter
            a = b
            if b > 1000000000:
                return -1
        else:
            b = a
            zero_counter += 1
        idx += 1
    return b
```