class Player
  def initialize()
    @health = 0
    @explored = {:backward => false, :forward => false}
  end
  
  def taking_damage?(warrior)
    return @health > warrior.health
  end
  
  def taking_damage_from_afar?(warrior, direction)
    (taking_damage?(warrior) and not warrior.feel(direction).enemy?)
  end
  
  def should_shoot?(warrior, direction)
    spaces_ahead =  warrior.look(direction)
    spaces_ahead.each do |space| 
      if space.enemy? 
        return true
      end
      if space.captive? 
        return false
      end
    end
    return false
  end

  def should_walk_in_opposite_direction?(warrior, direction)
    if finished_exploring?
      return false
    end
    
    spaces_ahead =  warrior.look(direction)

    if spaces_ahead.all?{|space| space.empty?}
      return false
    end 

    spaces_ahead.each do |space| 
      if space.enemy? 
        return false
      end
      
      if space.captive? 
        return false
      end
      
      if space.stairs? and not @explored[opposite(direction)]
        @explored[direction] = true   
        return true
      end
      
      if space.wall?
        @explored[direction] = true
        return true
      end
      
      if space.empty? 
        return false
      end
    end
    return false
  end
  
  def opposite(direction)
    if direction == :backward
      :forward
    else
      :backward
    end
  end
  
  def act(warrior, direction)
    @explored[direction] = warrior.feel(direction).wall? or warrior.feel(direction).stairs?
    
    if should_shoot?(warrior, direction)
      warrior.shoot!(direction)  
    else
      if taking_damage_from_afar?(warrior, direction)
        warrior.walk!(opposite(direction))
      else
        if warrior.feel(direction).empty?
          if warrior.health < 10 and not taking_damage?(warrior)
            warrior.rest!
          else
            if should_walk_in_opposite_direction?(warrior, direction)
              warrior.walk!(opposite(direction))
            else
              warrior.walk!(direction)
            end
          end
        else
          if warrior.feel(direction).captive?
            warrior.rescue!(direction)
          else 
            warrior.attack!(direction)
          end
        end
      end  
    end
  end

  def finished_exploring?
    @explored[:backward] and  @explored[:forward]
  end

  def play_turn(warrior)
    if @health == 0
      @health = warrior.health
    end
  
    if warrior.feel.wall?
      warrior.pivot!
    else
      if not @explored[:backward]
        act(warrior, :backward)
      else
        act(warrior, :forward)
      end
    end

    @health = warrior.health
  end
end