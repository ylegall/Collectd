
module collectd.util;


import std.container;
import std.traits;

version(unittest) {
	import std.stdio;
}

/*
 * Utility template that provides a growable heap
 */
template Heap(T, alias less = "a < b")
{
	auto Heap = BinaryHeap!(Array!(T), less)();
}

unittest
{
	auto h = Heap!int;
	h.insert(3);
	h.insert(7);
	h.insert(5);
	assert(h.front == 7);
}

/*
 * useful template for associative arrays:
 * update: associative arrays now support the "clear" property.
 */
template Maps(K,V)
{
	// an empty map for a quick way to clear a hash:
	V[K] empty;
}

template Maps(alias T)
{
	// an empty map for a quick way to clear a hash:
	alias KeyType!(typeof(T)) K;
	alias ValueType!(typeof(T)) V;
	V[K] empty;
}

unittest
{
	int[int] map;
	map[1] = 2;
	assert(map.length);
	map = Maps!(map).empty;
	assert(map.length == 0);
	map[3] = 5;
	assert(map.length);
	map = Maps!(int, int).empty;
	assert(map.length == 0);
}

alias RedBlackTree TreeSet;
alias redBlackTree treeSet;

unittest
{
	auto s = treeSet!(int);
	s.insert(5);
	assert(5 in s);
}

