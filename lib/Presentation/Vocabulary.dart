import 'dart:math';

class Vocabulary {
  Vocabulary(this._bookName, this._unitName, this._word, this._meaning,
      this._type, this._synonym, this._description, this._ownDescription);
  String _bookName;
  String _unitName;
  String _word;
  String _meaning;
  String _type;
  List<String> _synonym = [];
  String _description;
  String _ownDescription = 'Add your own description here';

  String getBookName() {
    return this._bookName;
  }

  String getUnitName() {
    return _unitName;
  }

  String getWord() {
    return _word;
  }

  String getType() {
    return _type;
  }

  String getSynonym() {
    return _synonym.join(', ');
  }

  String getMeaning() {
    return _meaning;
  }

  String getSingleSynonymBasedOnExam() {
    if (_synonym.isEmpty) {
      return "No synonyms available";
    }
    List<String> v = _synonym[Random().nextInt(_synonym.length)]
        .split(',')
        .map(
          (e) => e.trim(),
        )
        .where((synonym) => synonym.isNotEmpty) // Filter out empty synonyms
        .toList();
    if (v.isEmpty) {
      return "No valid synonyms available";
    }
    int x = Random().nextInt(v.length);
    print("    single based is : ${v[x]}");
    return v[x];
  }

  List<String> getMultipleSynonymBasedOnExam() {
  
    List<String> v = _synonym[Random().nextInt(_synonym.length)]
        .split(',')
        .map(
          (e) => e.trim(),
        )
        .where((synonym) => synonym.isNotEmpty) // Filter out empty synonyms
        .toList();
    return v;
  }

  String getOwnDescription() {
    return _ownDescription;
  }

  String getDescription() {
    return _description;
  }

  void setWord(String word) {
    this._word = word;
  }

  void setType(String type) {
    this._type = type;
  }

  void setSynonym(String synonym) {
    List<String> newSynonyms = synonym
        .split(',')
        .map(
          (e) => e.trim(),
        )
        .toList();

    _synonym.clear();
    // Iterate over new synonyms and add only those that don't already exist

    for (var newSynonym in newSynonyms) {
      print(" synoym split is : $newSynonym ");
      if (!_synonym.contains(newSynonym) && newSynonym.isNotEmpty) {
        _synonym.add(newSynonym);
      }
    }
  }

  void setDescription(String description) {
    this._description = description;
  }

  void setOwnDescription(String ownDescription) {
    this._ownDescription = ownDescription;
  }

  void setMeaning(String meaning) {
    this._meaning = meaning;
  }

  Map<String, dynamic> toMap() {
    StringBuffer textBuffer = StringBuffer();

    for (int i = 0; i < _synonym.length; i++) {
      textBuffer.write(_synonym[i]);
      if (i < _synonym.length - 1) {
        textBuffer.write(', ');
      }
    }

    return {
      'bookName': _bookName,
      'unitName': _unitName,
      'word': _word,
      'meaning': _meaning,
      'type': _type,
      'synonym': textBuffer.toString(),
      'description': _description,
      'ownDescription': _ownDescription
    };
  }

  void printMessage() {
    print("values are : ${_unitName + _word}");
  }
}
