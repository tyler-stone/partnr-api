module V1::Entities
  class SkillscoreData < Grape::Entity
    expose :scored do
      expose :skills do |inst, opts|
        inst.scored_skills.each { |hsh| hsh[:skill] = SkillData::AsFull.represent(hsh[:skill]) }
      end
      expose :categories do |inst, opts|
        inst.scored_categories.each { |hsh| hsh[:category] = CategoryData::AsFull.represent(hsh[:category]) }
      end
    end
    expose :raw do
      expose :skills, using: SkillData::AsFull
      expose :categories, using: CategoryData::AsFull
    end
  end
end
