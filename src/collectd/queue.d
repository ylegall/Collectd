
module collectd.queue;

import std.conv;
import collectd.collection;


abstract class Queue(T) : AbstractCollection!T
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

	this () {

	}

	override
	void clear() {
		len = 0;
		data.length = 0;
	}

	override
	void add(T item) {
		if (len >= data.length) {
			data.length = std.algorithm.max(1,data.length);
			data.length *= 2;
		}
		data[len] = item;
		len++;
	}

	T remove() {
		T item = data[0];
		len--;
		data = data[1..$];
		return item;
	}

	void removeAll(T[] items ...) {
		foreach (item; items) {
			remove(item);
		}
	}

	T peek() {
		return data[0];
	}

	int opApply(int delegate(T) d) {
		int result = 0;
		for (int i=0; i < len; ++i) {
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
	}

	this() {
		clear();
	}

	override
	void clear() {
		len = 0;
		head = tail = null;
	}

	T peek() {
		assert (len, "queue is empty");
		return head.data;
	}

	override
	void add(T item) {
		Node* n = new Node(item);
		if (len == 0) {
			head = tail = n;
		} else {
			tail.next = n;
			tail = tail.next;
		}
		len++;
	}
	alias add enqueue;

	void addAll(T[] items ...) {
		foreach (item; items) {
			add(item);
		}
	}

	public T remove() {
		assert (len, "queue is empty");
		auto retval = head.data;
		head = head.next;
		--len;
		if (len == 0) {
			clear();
		}
		return retval;
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

