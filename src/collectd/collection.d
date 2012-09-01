
module collectd.collection;

interface Collection(T)
{
	size_t size();

	bool isEmpty();

	void add(T item);

	void addAll(A)(A items);

	bool remove(T item);

	void removeAll(T[] items ...);

	void clear();
}

