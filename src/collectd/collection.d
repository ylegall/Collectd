
module collectd.collection;

interface Collection(T)
{
	size_t length();

	bool isEmpty();

	void add(T item);

	void addAll(T)(T[] items);

	bool remove(T item);

	void removeAll(T[] items ...);

	void clear();
}

abstract class AbstractCollection(T) : Collection!T
{
	protected size_t len;

	this () {
		len = 0;
	}

	void add(T item) {
		len++;
	}

	bool remove(T item) {
		if (len == 0) {
			return false;
		}
		len--;
		return true;
	}

	@property
	bool isEmpty() {
		return len == 0;
	}

	@property
	size_t length() {
		return len;
	}

	void clear() {
		len = 0;
	}

	void addAll(T[] items ...) {
		len += items.length;
	}

	void opOpAssign(string op)(T item) {
		static if (op == "+") {
			add(item);
		} else if (op == "-") {
			remove(item);
		}
	}
}

