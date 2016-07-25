#!/bin/ruby

class Images
  include Comparable

  attr_accessor :id, :tag, :date, :name

  def <=>(anOther)
    return self.date <=> anOther.date
  end

  def ==(other)
    return self.id == other.id && self.tag == other.tag && self.name == other.name && self.date == other.date
  end

  def initialize(id,tag,date,name)
    @id=id
    @tag=tag
    @date=date
    @name=name
  end

  def getId()
    @id
  end

  def getTag()
    @tag
  end

  def getDate()
    @date
  end

  def getName()
    @name
  end
end
