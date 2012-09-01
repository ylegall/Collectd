
module collectd.set;

import collectd.collection;
import std.conv;
import std.traits;

version (unittest) {
	import std.stdio;
}

interface Set(T) : Collection!T
{

}

//class HashSet(T: immutable(T)) : Set!T
class HashSet(T) : Set!T
{
	enum MIN_SIZE = 8;
	enum EXP_FACTOR = 2;

	private {
		size_t mySize;
		double loadFactor;
		Node*[] data;
	}

	public this(double loadFactor=0.75) {
		mySize = 0;
		this.loadFactor = loadFactor;
		data.length = 8;
	}

	@property
	public size_t size() {
		return mySize;
	}

	public void clear() {
		mySize = 0;
		data = null;
		data = new Node*[MIN_SIZE];
	}
	unittest {
		Set!int s = new HashSet!int();
		foreach (i; 0 .. 10) {
			s.add(i);
		}
		writeln(s);
		s.clear();
		assert(s.isEmpty());
		writeln(s);
	}

	bool isEmpty() {
		return size > 0;
	}

	// gets the index of the specified item in the array
	private auto getIndex(T item) {
		auto index = typeid(item).getHash(&item) % data.length;
		while (data[index] !is null) {
			if (data[index].val == item) {
				break;
			} else {
				index = typeid(item).getHash(&item) % data.length;
			}
		}
		return index;
	}

	public bool contains(T item) {
		auto index = getIndex(item);
		if (data[index] == null || data[index].val != item) {
			return false;
		}
		return true;
	}
	unittest {
		auto s = new HashSet!int();
		s.addAll([1,2,3,4,5]);
		assert(s.contains(3));
		assert(!s.contains(6));
	}

	public void add(T item) {
		if ((mySize + 1)/(cast(double)data.length) > loadFactor) {
			resize(false);
		}
		auto index = getIndex(item);
		Node* newNode = new Node(item);
		data[index] = newNode;
		mySize++;
	}
	alias add insert;

	public void addAll(A)(A items)
		if (isIterable!(A))
	{
		foreach(item; items) {
			add(item);
		}
	}

	public bool remove(T item) {
		auto index = getIndex(item);
		if (data[index] == null) {
			return false;
		} else if (data[index].val == item) {
			data[index] = null;
			mySize--;
			if (mySize < data.length/EXP_FACTOR && data.length > MIN_SIZE) {
				shrink();
			}
			return true;
		}
		return false;
	}

	public void removeAll(T[] items) {
		foreach (item; items) {
			remove(item);
		}
	}

	public void opOpAssign(string op)(T item) {
		static if (op == "+") {
			add(item);
		} else if (op == "-") {
			remove(item);
		}
	}

	private void resize(bool shrink=false) {
		Node*[] new_data;
		auto len = data.length;
		if (shrink && len > MIN_SIZE) {
			new_data.length = len / EXP_FACTOR;
		} else {
			new_data.length = len * EXP_FACTOR;
		}

		auto old_data = data;
		data = new_data;
		foreach(i; 0 .. old_data.length) {
			if (old_data[i] !is null) {
				add(old_data[i].val);
			}
		}
	}
	void expand() {resize();}
	void shrink() {resize(true);}

	public string toString() {
		if (size == 0) return "[]";
		auto str = "[";
		foreach(i; 0 .. data.length) {
			if (data[i] !is null) {
				str ~= (to!string(data[i].val) ~ ",");
			}
		}
		return str[0 .. $-1] ~ "]";
	}

	int opApply(int delegate(ref Node*) dg) {
		int result = 0;
		foreach (i; 0 .. data.length) {
			if (data[i]) {
				result = dg(data[i]);
				if (result)
					break;
			} else {
				continue;
			}
		}
		return result;
	}

	private struct Node {
		immutable(T) val;
		this(T v) {val=v;}
	}
}

