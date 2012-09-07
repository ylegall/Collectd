
module collectd.stack;
import collectd.collection;

import std.string;
import std.conv;

version (unittest) {
	import std.stdio;
}


abstract class Stack(T) : AbstractCollection!T
{
	alias add push;
	T remove();
	alias remove pop;
}


class LinkedStack(T) : Stack!T
{
	private Node* top;

	this() {
		clear();
	}

	void clear() {
		len = 0;
		top = null;
	}
	unittest {
		auto s = new LinkedStack!int();
		s += 15;
		s.clear();
		assert(s.isEmpty, "LinkedStack should be empty");
		assert(s.length == 0);
	}

	void add(T item) {
		Node* n = new Node(item, top);
		top = n;
		len++;
	}
	unittest {
		auto s = new LinkedStack!int();
		s += 15;
		assert(!s.isEmpty, "LinkedStack is not empty");
		assert(s.length == 1);
	}

	void addAll(T[] items ...) {
		foreach (item; items) {
			push(item);
		}
	}

	T remove() {
		assert(len);
		Node* n = top;
		top = top.prev;
		len--;
		return n.data;
	}
	unittest {
		auto s = new LinkedStack!int();
		s.push(1);
		s.push(2);
		s.push(3);
		assert(s.pop() == 3);
		s.push(4);
		assert(s.pop() == 4);
		assert(s.pop() == 2);
		assert(s.pop() == 1);
		assert(s.isEmpty, "LinkedStack should be empty");
	}

	bool remove(T item) {
		throw new Exception("remove: unsupported operation");
	}

	void removeAll(T[] items ...) {
		throw new Exception("removeAll: unsupported operation");
	}

	string toString() {
		string s = "[";
		auto n = top;
		while (n) {
			s ~= to!string(n.data);
			s ~= ",";
			n = n.prev;
		}
		s = s[0 .. $-1];
		s ~= "]";
		return s;
	}

	int opApply(int delegate (ref T) d) {
		int result = 0;
		Node* n = top;
		while (n) {
			result = d(n.data);
			if (result) return result;
			n = n.prev;
		}
		return result;
	}

	struct Node
	{
		T data;
		Node* prev;

		this(T item, Node* n) {
			data = item;
			prev = n;
		}
	}
}


class ArrayStack(T) : Stack!T
{
	private T[] data;

	this(size_t cap = 8) {
		data.length = cap;
		len = 0;
	}

	void clear() {
		len = 0;
		data.length = 0;
	}

	void add(T item) {
		if (len >= data.length) {
			data.length *= 2;
		}
		data[len] = item;
		len++;
	}

	void addAll(T[] items ...) {
		foreach (item; items) {
			push(item);
		}
	}

	T remove() {
		assert(len);
		if (len < data.length/2) {
			data.length /= 2;
		}
		len--;
		return data[len];
	}

	bool remove(T item) {
		throw new Exception("remove: unsupported operation");
	}

	void removeAll(T[] items ...) {
		throw new Exception("removeAll: unsupported operation");
	}

	string toString() {
		return to!string(data[0 .. len]);
	}

	void opIndexAssign(T item, size_t index) {
		data[index] = item;
	}

	void opIndexOpAssign(string op)(T item, size_t index) {
		mixin("data[index]" ~ op ~ "= item;");
	}

	int opApply(int delegate (ref T) d) {
		int result = 0;
		foreach (i; 0 .. 10) {
			result = d(data[i]);
			if (result) return result;
		}
		return result;
	}
}


version (single)
{
	import std.stdio;
	void main()
	{
		//auto s = new ArrayStack!int();
		auto s = new LinkedStack!int();

		foreach (i; 0 .. 10) {
			s.push(i);
		}
		s += 42;
		writeln(s);

		foreach (item; s) {
			writeln("item = ", item);
		}
	}
}

