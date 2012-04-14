//(function() {
  var jDataViewReader;

  jDataViewReader = (function() {

    function jDataViewReader(dataView) {
      this.dataView = dataView;
      this.pos = 0;
    }

    jDataViewReader.prototype.size = function() {
      return this.dataView.size();
    };

    jDataViewReader.prototype.readInt8 = function() {
      var res;
      res = this.dataView.getInt8(this.pos);
      ++this.pos;
      return res;
    };

    jDataViewReader.prototype.readUInt8 = function() {
      var res;
      res = this.dataView.getUInt8(this.pos);
      ++this.pos;
      return res;
    };

    jDataViewReader.prototype.readInt16 = function(littleEndian) {
      var res;
      res = this.dataView.getInt16(this.pos, littleEndian);
      this.pos += 2;
      return res;
    };

    jDataViewReader.prototype.readUInt16 = function(littleEndian) {
      var res;
      res = this.dataView.getUInt16(this.pos, littleEndian);
      this.pos += 2;
      return res;
    };

    jDataViewReader.prototype.readInt32 = function(littleEndian) {
      var res;
      res = this.dataView.getInt32(this.pos, littleEndian);
      this.pos += 4;
      return res;
    };

    jDataViewReader.prototype.readUInt32 = function(littleEndian) {
      var res;
      res = this.dataView.getUInt32(this.pos, littleEndian);
      this.pos += 4;
      return res;
    };

    jDataViewReader.prototype.readFloat = function(littleEndian) {
      var res;
      res = this.dataView.getFloat32(this.pos, littleEndian);
      this.pos += 4;
      return res;
    };

    jDataViewReader.prototype.readDouble = function(littleEndian) {
      var res;
      res = this.dataView.getFloat64(this.pos, littleEndian);
      this.pos += 8;
      return res;
    };

    jDataViewReader.prototype.readChar = function() {
      var res;
      res = this.dataView.readChar(this.pos);
      ++this.pos;
      return res;
    };

    jDataViewReader.prototype.readString = function() {
      var res;
      return res = this.dataView.readString(length, this.pos);
    };

    jDataViewReader.prototype.seek = function(pos) {
      this.pos = pos;
      this.dataView.seek(this.pos);
    };

    jDataViewReader.prototype.tell = function() {
      return this.pos;
    };

    return jDataViewReader;

  })();

exports.jDataViewReader = jDataViewReader
//}).call(this);
