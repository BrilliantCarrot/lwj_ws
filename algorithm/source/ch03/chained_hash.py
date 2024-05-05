# 체인법으로 해시 함수 구현하기

from __future__ import annotations
from typing import Any, Type
import hashlib

class Node:
    """해시를 구성하는 노드"""

    def __init__(self, key:Any, value:Any, next:Node) -> None:
        """초기화"""
        self.key = key
        self.value = value
        self.next = next


class ChainedHash:
    """체인법으로 해시 클래스 구현"""

    def __init__(self, capacity: int) -> None:
        """초기화"""
        self.capacity = capacity
        self.table = [None] * self.capacity

    def hash_value(self, key:Any) -> int:
        """해시값을 구함"""
        if isinstance(key, int):
            return key % self.capacity
        return(int(hashlib.sha256(str(key).sncode()).hexdigest(),16)%self.capacity)