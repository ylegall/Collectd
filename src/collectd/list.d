
module collectd.list;

import collectd.collection;
import std.conv;

/*
 *
 */
abstract class List(T) : AbstractCollection!T
{
	void insert(T item, size_t index);

	T get(size_t index);

	void set(size_t index, value);
}

/*
 *
 */
class ArrayList(T) : List!T
{
	enum GROWTH_FACTOR = 1.8;
	private T[] data;

	override void add(T item) {
		if (len == data.length) {
			data.length *= GROWTH_FACTOR;
		}
		data[len++] = item;
	}

	void insert(T item, size_t index) {
		//TODO
	}

	T get(size_t index) {
		assert(index < len);
		return data[index];
	}

	mixin Indexor!(T);
}


/*
 *
 */
class LinkedList(T) : List!T
{
	private Node* head;
	private Node* tail;

	this() {
		super();
		head = null;
		tail = null;
	}

	void add(T item) {
		super.add(item);
		auto n = new Node(item,null);
		if (tail) {
			tail.next = n;
			tail = tail.next;
		} else {
			head = tail = n;
		}
	}

	void insert(T item, size_t index) {
		auto n = new Node(item, null);
		auto current = head;
		if (!current) {
			add(item);
			return;
		}
		while (true) {
			auto next = current.next;
			writeln("current: ", current.val);
			if (index == 0) {
				current.next = n;
				n.next = next;
				len++;
				return;
			}
			index--;
			current = current.next;
		}
		throw new Exception("index out of bounds.");
	}

	T get(size_t index) {
		if (index >= len) {
			throw new Exception("index out of bounds.");
		}
		Node* current = head;
		auto count = 0;
		while (current) {
			if (!index) {
				return current.val;
			}
			index--;
			current = current.next;
		}
		throw new Exception("index out of bounds.");
	}

	string toString() {
		auto s = "[";
		auto current = head;
		while (current) {
			s ~= to!string(current.val);
			s ~= ",";
			current = current.next;
		}
		return s[0 .. $-1] ~ "]";
	}

	private struct Node
	{
		T val;
		Node* next;

		this (T val, Node* next) {
			this.val = val;
			this.next = next;
		}
	}
}

version (single)
{
	import std.stdio;

	void main() {
		auto l = new LinkedList!int();
		l.add(34);
		l += 43;
		l += 54;
		writeln(l);
		l.insert(17,1);
		writeln(l);
		writeln(l.length);
		writeln(l.get(1));
	}
}

