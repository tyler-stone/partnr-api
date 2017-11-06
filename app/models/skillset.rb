class Skillset < ActiveRecord::Base
  belongs_to :user

  def calculate
    @skillscore ||= calculate_score
  end

  def tasks
    @tasks ||= user.tasks
  end

  def completed_tasks
    @completed_tasks ||= tasks.complete
  end

  def skills
    # this also removes duplicates
    @skills ||= tasks.collect { |t| t.skills }.flatten
  end

  def skills_duplicated
    @skills_duplicated ||= get_skills_with_duplicates
  end

  def categories
    # this also removes duplicates
    @categories ||= tasks.collect { |t| t.categories }.flatten
  end

  def categories_duplicated
    @categories_duplicated ||= get_categories_with_duplicates
  end

  def scored_skills
    @scored_skills ||= primitive_skill_score
  end

  def scored_categories
    @scored_categories ||= primitive_category_score
  end

  private

  def get_skills
    tasks.collect { |t| t.skills }.flatten
  end

  def get_categories
    tasks.collect { |t| t.categories }.flatten
  end

  def get_skills_with_duplicates
    duplicates_list = []
    completed_tasks.each do |task|
      task.skills.each do |skill| 
        duplicates_list.push skill
      end
    end
    duplicates_list
  end

  def get_categories_with_duplicates
    duplicates_list = []
    completed_tasks.each do |task|
      task.categories.each do |category|
        duplicates_list.push(category)
      end
    end
    duplicates_list
  end

  def primitive_category_score
    primitive_score get_categories_with_duplicates, :category
  end

  def primitive_skill_score
    primitive_score get_skills_with_duplicates, :skill
  end

  def primitive_score(collection, symbol)
    counted_hash = Hash.new(0)
    # count the entities
    collection.each do |entity|
      counted_hash[entity] += 1
    end

    # put each entity and score in an array to return
    scored_entity_array = []
    counted_hash.each do |entity, count|
      scored_entity_array.push({ symbol => entity, :score => count })
    end
    scored_entity_array
  end

  def calculate_score
    skillcount = skills_duplicated.each_with_object(Hash.new(0)) { |skill,counts| counts[skill.title] += 1 }
    catcount = categories_duplicated.each_with_object(Hash.new(0)) { |cat,counts| counts[cat.title] += 1 }
    {
      :skills => skillcount,
      :categories => catcount
    }
  end
end
