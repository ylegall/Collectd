
module util.avl;

import std.stdio;
import std.cstream;
import std.conv;

template TreeT(T) {

class Tree
{
	private Node* root;
	private size_t size;
	private int function(T,T) compare;

	this() {
		this(null);
	}

	this(int function(T,T) func) {
		root = null;
		size = 0;
		compare = &defaultCompare;
		if (func) compare = func;
	}

	this(T item, Tree l, Tree r) {
		root = new Node(item);
		root.left = l.root;
		root.right = r.root;
		size = 1 + l.size + r.size;
	}

	@property
	public auto length() { return size; }

	@property
	public auto empty() { return size == 0; }

	@property
	T front() {	return this.getMin(); }

	@property
	T back() { return this.getMax(); }

	// TODO implement popFront
	// TODO implement popBack

	public void clear() {
		size = 0;
		root = null;
	}

	/**
	 *
	 */
	public void add(T item) {
		root = add(item, root);
		size++;
	}

	private Node* add(T item, Node* node) {
		if (node == null) {
			return new Node(item);
		}

		auto val = compare(node.data, item);
		if (val > 0) {
			node.left = add(item, node.left);
			if (node.balance() >= 2) {
				if (compare(node.left.data, item) > 0) {
					node = singleRotateRight(node);
				} else {
					node = doubleRotateRight(node);
				}
			}
		} else if (val < 0) {
			node.right = add(item, node.right);
			if (node.balance() <= -2) {
				if (compare(node.right.data, item) < 0) {
					node = singleRotateLeft(node);
				} else {
					node = doubleRotateLeft(node);
				}
			}
		} else {}

		// update the height
		node.updateHeight();
		return node;
	}
	alias add insert;

	/**
	 *
	 */
	public T remove(T item) {
		root = remove(item, root);
		size--;
	}

	//TODO implement
	private Node* remove(T item, Node* node) {
		//TODO implement
	}

	// gets the largest node of the leftmost subtree of parent
	private Node* removeMaxLeft(Node* current, Node* parent) {
		while (current.right) {
			parent = current;
			current = current.right;
		}
		parent.right = current.left;
		current.left = null;
		return current;
	}

	/**
	 *
	 */
	public void opOpAssign(string op)(T item) {
		static if (op == "+") {
			add(item);
		} else if (op == "-") {
			remove(item);
		}
	}

	private Node* singleRotateRight(Node* node) {
		Node* A = node.left;
		Node* Ar = A.right;
		A.right = node;
		node.left = Ar;
		A.updateHeight();
		node.updateHeight();
		return A;
	}

	private Node* doubleRotateRight(Node* node) {
		Node* A = node.left;
		Node* B = A.right;
		Node* Bl = B.left;
		node.left = B;
		B.left = A;
		A.right = Bl;
		return singleRotateRight(node);
	}

	private Node* singleRotateLeft(Node* node) {
		Node* A = node.right;
		Node* Al = A.left;
		A.left = node;
		node.right = Al;
		A.updateHeight();
		node.updateHeight();
		return A;
	}

	private Node* doubleRotateLeft(Node* node) {
		Node* A = node.right;
		Node* B = A.left;
		Node* Br = B.right;
		node.right = B;
		B.right = A;
		A.left = Br;
		return singleRotateLeft(node);
	}

	/**
	 * See if the element is in this set
	 */
	public bool contains(T item) {
		return find(item) !is null;
	}

	private Node* find(T item) {
		Node* current = root;
		while (current) {
			auto val = compare(current.data, item);
			if (val == 0) {
				return current;
			}
			if (val > 0) {
				current = current.left;
			} else {
				current = current.right;
			}
		}
		return null;
	}

	bool opBinaryRight(string op)(T item) {
		static if (op == "in") {
			return contains(item);
		}
	}

	public T getMax() {
		return findMaxOrMin(true);
	}

	public T getMin() {
		return findMaxOrMin(false);
	}

	private T findMaxOrMin(bool max) {
		assert(size > 0);
		Node* current = root;
		while (true) {
			if (current.isLeaf()) {
				return current.data;
			}
			current = (max)? current.right : current.left;
		}
		throw new Exception("item not found");
	}

	public string toString() {
		return "[" ~ getString(root)[0..($-1)] ~ "]";
	}

	private string getString(Node* node) {
		if (node == null) {
			return "";
		}
		return
			getString(node.left) ~
			to!string(node.data) ~ "," ~
			getString(node.right);
	}

	/**
	 * for debugging
	 */
	void print_tree() {
		print_tree(root, 0);
		writeln();
	}

	/**
	 * for debugging
	 */
	private void print_tree(Node* node, int depth) {
		if (node == null) {
			foreach (i; 0..depth) { write("  "); }
			write("()");
			return;
		}

		foreach (i; 0..depth) { write("  "); }

		if (node.isLeaf()) {
			write("(",node.data,")");
		} else {
			write("(",node.data);
			writeln();
			print_tree(node.left, depth + 1);
			writeln();
			print_tree(node.right, depth + 1);
			writeln();
			foreach (i; 0..depth) { write("  "); }
			write(")");
		}
	}

	private struct Node {
		T data;
		Node* left;
		Node* right;
		int height;

		this(T item) {
			data = item;
			left = right = null;
			height = 0;
		}

		bool isLeaf() {
			return (left == null) && (right == null);
		}

		auto balance() {
			auto hl = (left )? left.height  : -1;
			auto hr = (right)? right.height : -1;
			return hl - hr;
		}

		void updateHeight() {
			auto hl = (left)?  left.height  : -1;
			auto hr = (right)? right.height : -1;
			height = max(hl, hr) + 1;
		}
	}

} // end Tree

int defaultCompare(T a, T b) {
	if (a > b) { return 1; }
	else if (b > a) { return -1; }
	return 0;
}

T max(T a, T b) {
	return (a > b)? a : b;
}

} // end template

alias TreeT!(int).Tree IntTree;

auto avlTree(T)(T[] items...) {
	auto avl = new TreeT!(T).Tree();
	foreach(item; items) {
		avl.add(item);
	}
	return avl;
}


int main() {

	auto t = avlTree(1,2,3,4,5,6);
	writeln(t);

//	IntTree t = new IntTree();
//	t.add(5);
//	t.print_tree();
//	t.add(2);
//	t.add(9);
//	t.add(6);
//	t.add(4);
//	t.add(1);
//	t.add(8);
//	t.add(3);
//	t.print_tree();
//	writeln(7 in t);
//	writeln(t.contains(6));
//	writeln(t);
//	writeln(t.getMax());
//	writeln(t.getMin());

	return 0;
}

