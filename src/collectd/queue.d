
module collectd.queue;

import std.conv;
import collectd.collection;


interface Queue(T) : Collection!T
{
	//void add(T item);
	alias add offer;
	alias add enqueue;

	T remove();
	alias remove poll;
	alias remove dequeue;

	T peek();
}

class ArrayQueue(T) : Queue!T
{
	private T[] data;
	private size_t s;

	this () {

	}

	@property
	size_t size() {
		return s;
	}

	@property
	bool empty() {
		return s == 0;
	}

	void clear() {
		s = 0;
		data.length = 0;
	}

	void add(T item) {
		if (s >= data.length) {
			data.length = std.algorithm.max(1,data.length);
			data.length *= 2;
		}
		data[s] = item;
		s++;
	}

	T remove() {
		assert(s);
		T item = data[0];
		s--;
		data = data[1..$];
		return item;
	}

	void removeAll(T[] items ...) {
		foreach (item; items) {
			remove(item);
		}
	}

	T peek() {
		assert(s);
		return data[0];
	}

	int opApply(int delegate(T) d) {
		int result = 0;
		for (int i=0; i < s; ++i) {
			result = d(data[i]);
			if (result) return result;
		}
		return result;
	}

}

class LinkedQueue(T) : Queue!T
{
	private {
		Node* head;
		Node* tail;
		size_t s;
	}

	this() {
		clear();
	}

	void clear() {
		s = 0;
		head = tail = null;
	}

	@property
	size_t size() {
		return s;
	}

	bool isEmpty() {
		return s == 0;
	}

	void opOpAssign(string op)(T item) {
		static if (op == "+") {
			add(item);
		}
	}

	T peek() {
		if (s > 0) {
			return head.data;
		} else {
			throw new Exception("queue is empty.");
		}
	}

	void add(T item) {
		Node* n = new Node(item);
		if (s == 0) {
			head = tail = n;
		} else {
			tail.next = n;
			tail = tail.next;
		}
		s++;
	}
	alias add enqueue;

	void addAll(T[] items ...) {
		foreach (item; items) {
			add(item);
		}
	}

	public T remove() {
		if (s > 0) {
			auto retval = head.data;
			head = head.next;
			s--;
			if (s == 0) {
				clear();
			}
			return retval;
		} else {
			throw new Exception("queue is empty.");
		}
	}

	bool remove(T item) {
		throw new Exception("remove: unsupported operation");
	}

	void removeAll(T[] items ...) {
		throw new Exception("removeAll: unsupported operation");
	}

	bool contains(T item) {
		auto current = head;
		while (current) {
			if (current.data == item) {
				return true;
			}
			current = current.next;
		}
		return false;
	}

	public string toString() {
		if (isEmpty()) return "[]";
		string str = "[";
		Node* current = head;
		while (current != null) {
			str ~= to!string(current.data);
			str ~= ",";
			current = current.next;
		}
		str = str[0 .. str.length-1] ~ "]";
		return str;
	}

	int opApply(int delegate(ref T t) dg) {
		int result = 0;
		Node* current = head;
		while (current != null) {
			result = dg(current.data);
			if (result) return result;
			current = current.next;
		}
		return result;
	}

	private struct Node
	{
		T data;
		Node* next = null;

		this(T item) {
			data = item;
		}
	}
}

unittest {
	auto q = new LinkedQueue!int();
	q.addAll(1,3,5);
	assert(q.remove == 1);
	assert(q.remove == 3);
	assert(q.remove == 5);
	assert(q.isEmpty());
}

