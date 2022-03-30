import Foundation

let dataFileName = "treeworksData.json"

let dataFileDir: String = NSSearchPathForDirectoriesInDomains(
FileManager.SearchPathDirectory.documentDirectory, 
FileManager.SearchPathDomainMask.allDomainsMask, true)
.first! + "/" + dataFileName


var jsonString: String = ""
var dataInMemory: Data?
var changesNotSaved = false

class Word: Codable {
	var value: String
	var inside: [Word]

	init(value: String, inside: [Word]){
		self.value = value
		self.inside = inside
	}
}

do {
	dataInMemory = try Data(String(contentsOf: URL(fileURLWithPath: dataFileDir), encoding: .utf8).utf8)
} catch {
	dataInMemory = Data("{ \"value\": \"root\", \"inside\": []}".utf8)
	print("\nNo save file. New file will be created: (username)/Documents/data.json")
}
let decoder = JSONDecoder()
let root = try decoder.decode(Word.self, from: dataInMemory!)

var currentNode: Word = root
var currentPath: [Word] = [root] 
var buffer: Word? 

func intro() {
	let intro = 
		"""
		\n
		TREE TEXT EDITOR by Gleb Micnovic.

		Type 'p' to see the words at the current path.
		Type 'h' to see the list of commands.
		Type 'q' to exit.
		"""

		print(intro)

		mainLoop()
}
func mainLoop() {
		let inputLine = readLine(strippingNewline: true)!
		let inputArguments: [String] = inputLine.components(separatedBy: " ")
		var inputIndex: Int?
		if inputArguments.count > 1 {
			inputIndex = Int(inputArguments[1])
		}

		for _ in 0..<30 { print("") }

		if inputArguments[0] == "p" {
			printCurrentNode()
			mainLoop()
		} else if inputArguments[0] == "s" {
			save()
			print("Saved.")
			printCurrentNode()	
			mainLoop()
		} else if inputArguments[0] == "w" {
			changesNotSaved = true
			var newWordValue = ""
			if inputArguments.count > 1 {
				var inputArgumentsArray = inputArguments as [String]
				inputArgumentsArray.remove(at: 0)
				newWordValue = inputArgumentsArray.joined(separator: " ")
			} else {
				print("Insert new word:")
				newWordValue = readLine(strippingNewline: true)!
			}
			let newWord = Word(value: newWordValue, inside: [])
			currentNode.inside.append(newWord)
			printCurrentNode()
			changesNotSaved = true
			mainLoop()
		} else if inputArguments[0] == "c" {
			if inputIndex == nil {
				print("Select index to copy: ")
				inputIndex = Int(readLine(strippingNewline: true)!)!
			}
			if inputIndex! >= 0 && inputIndex! <= currentNode.inside.count - 1 {
				buffer = copySubtree(currentNode.inside[inputIndex!])
			} else {
				print("Invalid index")
			}
			printCurrentNode()
			mainLoop()
		} else if inputArguments[0] == "paste" {
			if inputIndex == nil {
				print("Select index to paste: ")
				inputIndex = Int(readLine(strippingNewline: true)!)!
			}
			if buffer != nil {
				if inputIndex! >= 0 && inputIndex! <= currentNode.inside.count - 1 {
					currentNode.inside[inputIndex!] = buffer!
				} else if inputIndex! == currentNode.inside.count {
					currentNode.inside.append(buffer!)
					printCurrentNode()
					changesNotSaved = true
				} else {
					print("Invalid index")
				}
			} else {
				print("Buffer is empty")
			}
			mainLoop()
		} else if inputArguments[0] == "e" {
			if inputIndex == nil {
				print("Index to edit:")
				inputIndex = Int(readLine(strippingNewline: true)!)!
			}
			if inputIndex! >= 0 && inputIndex! <= currentNode.inside.count - 1 {
				print("Change \"\(currentNode.inside[inputIndex!].value)\" to:")
				let inputEdit = readLine(strippingNewline: true)!
				currentNode.inside[inputIndex!].value = inputEdit
				printCurrentNode()
				changesNotSaved = true
			} else {
				print("Invalid index")
			}
			mainLoop()
		} else if inputArguments[0] == "d" {
			if inputIndex == nil {
				print("Delete at index:")
				inputIndex = Int(readLine(strippingNewline: true)!)!
			}
			if inputIndex! >= 0 && inputIndex! <= currentNode.inside.count - 1 {
				currentNode.inside.remove(at: inputIndex!)
				printCurrentNode()
				changesNotSaved = true
			} else {
				print("Invalid index")
				mainLoop()
			}
			mainLoop()
		} else if inputArguments[0] == "g" {
			if inputIndex == nil {
				print("To index:")
				inputIndex! = Int(readLine(strippingNewline: true)!)!
			}
			if inputIndex! >= 0 && inputIndex! <= currentNode.inside.count - 1 {
				currentPath.append(currentNode)
				currentNode = currentNode.inside[inputIndex!]
				printCurrentNode()
			} else {
				print("Invalid index")
			}
			mainLoop()
		} else if inputArguments[0] == "u" {
			if currentPath.count == 1 {
				print("Already in the top node")	
				printCurrentNode()
			} else {
				currentPath.removeLast()	
				currentNode = currentPath.last!
				printCurrentNode()
			} 
			mainLoop()
		} else if inputArguments[0] == "h" {
			print(
					"""
					p - print the words at the current path with indicies
					w - add a word at the current path
					w word - add a word at the current path
					e - edit a word
					c - copy
					paste - paste
					d - delete
					h - help. You are here
					q - quit
					q q or qq - quit without saving
					You can optionally add index after any command. For example: w 0
					""")
			mainLoop()
		} else if inputArguments[0] == "q" {
			if inputArguments.count > 1 {
				if inputArguments[1] == "q" {
					print("Exit.")	
				}
			} else {
				if changesNotSaved {
					print(
						"""
						Changes has not been saved. Do you want to save?\n
						Press q again to exit anyway or s to save.\n
						Or type anything to continue.
						"""
					)
					let inputLine = readLine(strippingNewline: true)!
					if inputLine == "q" {
						print("Exit.")
					} else if inputLine == "s" {
						save()
						print("Exit")
					} else {
						print("Continue.")
						printCurrentNode()
						mainLoop()
					}
				} else {
					print("Exit.")
				}
			}
		} else if inputArguments[0] == "qq" {
			print("Exit.")
		} else if inputArguments.count == 1 && Int(inputArguments[0]) != nil {
			inputIndex = Int(inputArguments[0])
			if inputIndex! >= 0 && inputIndex! <= currentNode.inside.count - 1 {
				currentPath.append(currentNode)
				currentNode = currentNode.inside[inputIndex!]
			} else {
				print("Invalid index")
			}
			printCurrentNode()
			mainLoop()
		} else if inputArguments.count > 0 {
			changesNotSaved = true
			var newWordValue = ""
			let inputArgumentsArray = inputArguments as [String]
			newWordValue = inputArgumentsArray.joined(separator: " ")
			let newWord = Word(value: newWordValue, inside: [])
			currentNode.inside.append(newWord)
			printCurrentNode()
			mainLoop()
		} else {
			print("Unknown command")
			mainLoop()
		}
}

func printCurrentNode(){
	print("Current word: " + currentNode.value)
	for (index, word) in currentNode.inside.enumerated() {
		print("\(index): \(word.value)")
	}
}

func save(){
	var dataToSave: String = ""
	func recursion(_ word: Word){
		dataToSave += "{\"value\": \"\(word.value)\", \"inside\":["
			for i in word.inside {
				recursion(i)
				dataToSave += ","
			}
		dataToSave += "]}"
	}
	recursion(root)
	print(dataToSave)
	do {
		try dataToSave.data(using: .utf8)!.write(to: URL(fileURLWithPath: dataFileDir))
	} catch { 
		print("Could not save file")
	}
	changesNotSaved = false
}

func copySubtree(_ word: Word) -> Word {
	let result = Word(value: word.value, inside: [])
	for i in word.inside {
		result.inside.append(copySubtree(i))
	}
	return result
}

intro()
