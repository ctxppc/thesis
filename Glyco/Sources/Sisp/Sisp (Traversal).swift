// Sisp © 2021–2022 Constantino Tsarouhas

extension Sisp {
	
	/// Accesses a value at given index path.
	subscript <IndexPath : Collection>(indexPath: IndexPath) -> Sisp where IndexPath.Element == Index {
		get { self[indexPath[...]] }
		set { self[indexPath[...]] = newValue }
		_modify { yield &self[indexPath[...]] }
	}
	
	/// Accesses a value at given index path.
	subscript <IndexPath : Collection>(indexPath: IndexPath) -> Sisp where IndexPath.Element == Index, IndexPath.SubSequence == IndexPath {
		
		get {
			guard let (index, deeperPath) = indexPath.splittingFirst() else { return self }
			switch index {
				case .position(let p):	return self[p][deeperPath]
				case .label(let l):		return self[l][deeperPath]
			}
		}
		
		set {
			if let (index, deeperPath) = indexPath.splittingFirst() {
				switch index {
					case .position(let p):	self[p][deeperPath] = newValue
					case .label(let l):		self[l][deeperPath] = newValue
				}
			} else {
				self = newValue
			}
		}
		
		_modify {
			if let (index, deeperPath) = indexPath.splittingFirst() {
				switch index {
					case .position(let p):	yield &self[p][deeperPath]
					case .label(let l):		yield &self[l][deeperPath]
				}
			} else {
				yield &self
			}
		}
		
	}
	
	/// A value that identifies a list element or structure child.
	enum Index {
		
		/// A value that identifies a list element.
		case position(Int)
		
		/// A value that identifies a structure element.
		case label(Label)
		
	}
	
	/// Accesses an element at given position in the list.
	///
	/// - Requires: `self` is a list.
	private subscript (position: Int) -> Sisp {
		
		get {
			guard case .list(let elements) = self else {
				preconditionFailure("Positional indexing not supported on values of type \(typeDescription)")
			}
			if position == elements.endIndex {
				return []
			} else {
				return elements[position]
			}
			
		}
		
		set {
			guard case .list(var elements) = self else {
				preconditionFailure("Positional indexing not supported on values of type \(typeDescription)")
			}
			if position == elements.endIndex {
				elements.append(newValue)
			} else {
				elements[position] = newValue
			}
			self = .list(elements)
		}
		
	}
	
	/// Accesses a child with given label in the structure.
	///
	/// - Requires: `self` is a structure.
	private subscript (label: Label) -> Sisp {
		
		get {
			guard case .structure(type: _, children: let children) = self else {
				preconditionFailure("Label indexing not supported on values of type \(typeDescription)")
			}
			return children[label] ?? []
		}
		
		set {
			guard case .structure(type: let type, children: var children) = self else {
				preconditionFailure("Label indexing not supported on values of type \(typeDescription)")
			}
			children[label] = newValue
			self = .structure(type: type, children: children)
		}
		
	}
	
}
