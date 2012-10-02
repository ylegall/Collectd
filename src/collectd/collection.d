
module collectd.collection;

interface Collection(T)
{
	size_t length();

	bool isEmpty();

	void add(T item);

	void addAll(T)(T[] items);

	bool remove(T item);

	//void removeAll(T[] items ...);

	void clear();
}

abstract class AbstractCollection(T) : Collection!T
{
	protected size_t len;

	this () {
		len = 0;
	}

	void add(T item) {
		++len;
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

mixin template Indexor(T)
{
	T opIndexAssign(T value, size_t i) {
		set(i, value);
		return value;
	}

	T opIndex(size_t index) {
		return get(index);
	}

	T opIndexOpAssign(string op)(T value, size_t index)
	{
		auto item = get(index);
		mixin("item " ~ op ~ "= value");
		set(index, item);
		return item;
	}
}


auto empty_map(K,V)() {
	V[K] empty;
	return empty;
}

