
module util.stack;

import std.string;
import std.conv;

import collectd.collection;


abstract class Stack(T) : Collection!T
{
	alias add push;
	alias remove pop;
}


class LinkedStack(T) : Stack!T
{
	private Node* top;
	private size_t len;

	this() {
		clear();
	}

	void clear() {
		len = 0;
		top = null;
	}

	@property
	bool isEmpty() { return len == 0; }

	@property
	size_t size() { return len; }

	void add(T item) {
		Node* n = new Node(item, top);
		top = n;
		len++;
	}
	void addAll(T[] items ...) {
		foreach (item; items) {
			push(item);
		}
	}
	alias add push;

	T remove() {
		assert(len);
		Node* n = top;
		top = top.prev;
		len--;
		return n.data;
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
	T[] data;
	size_t len;

	this(size_t cap = 8) {
		data.length = cap;
		len = 0;
	}

	@property
	size_t size() { return len; }

	@property
	bool isEmpty() { return len == 0; }

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
	alias add push;

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
	alias remove pop;

	bool remove(T item) {
		throw new Exception("remove: unsupported operation");
	}

	void removeAll(T[] items ...) {
		throw new Exception("removeAll: unsupported operation");
	}

	override
	string toString() {
		return to!string(data[0 .. len]);
	}

	void opOpAssign(string op)(T item) {
		static if (op == "+") {
			push(item);
		}
	}

	void opIndexAssign(T item, size_t index) {
		data[index] = item;
	}

	void opIndexOpAssign(string op)(T item, size_t index) {
		mixin("data[index]" ~ op ~ "= item;");
	}

	int opApply(int delegate (ref T) d) {
		int result = 0;
		foreach (i; 0 .. len) {
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
		auto s = new Stack!int();

		foreach (i; 0 .. 10) {
			s.push(i);
		}
		writeln(s);

		foreach (item; s) {
			writeln("item = ", item);
		}
	}
}

