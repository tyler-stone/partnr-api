# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
categories = [
  {
    :title => "Engineering",
    :description => "The application of science and math principles to design and construct useful products",
    :color_hex => "#ffca00",
    :icon_class => "fa-gears"
  },
  {
    :title => "Life Science",
    :description => "Any science that deals directly with living organisms and their mechanisms",
    :color_hex => "#00a67c",
    :icon_class => "fa-paw"
  },
  {
    :title => "Physical Science",
    :description => "Any science that explores non-living systems",
    :color_hex => "#00be3a",
    :icon_class => "fa-flask"
  },
  {
    :title => "Mathematics",
    :description => "The abstract science concerned with number, quantity, and space",
    :color_hex => "#191db3",
    :icon_class => "fa-percent"
  },
  {
    :title => "Software",
    :description => "Anything to do with programs that run on computational technology",
    :color_hex => "#ae009f",
    :icon_class => "fa-laptop"
  },
  {
    :title => "Electronics",
    :description => "Anything to do with the hardware that runs computation",
    :color_hex => "#ff7000",
    :icon_class => "fa-plug"
  },
  {
    :title => "Health Sciences",
    :description => "Having to do with the health of a population or individual",
    :color_hex => "#e20048",
    :icon_class => "fa-heartbeat"
  },
  {
    :title => "Agriculture",
    :description => "The science or practice of farming",
    :color_hex => "#c0f400",
    :icon_class => "fa-leaf"
  },
  {
    :title => "Education",
    :description => "Anything having to do with the process of giving instruction",
    :color_hex => "#009e8e",
    :icon_class => "fa-graduation-cap"
  },
  {
    :title => "Writing",
    :description => "Having to do with creating, analyzing, or editing text",
    :color_hex => "#8506a9",
    :icon_class => "fa-newspaper-o"
  },
  {
    :title => "Visual Art",
    :description => "Anything to do with arts created for the purpose of visual perception",
    :color_hex => "#d8005f",
    :icon_class => "fa-paint-brush"
  },
  {
    :title => "Music",
    :description => "Anything to do with arts created for the purpose of aural perception",
    :color_hex => "#600cac",
    :icon_class => "fa-music"
  },
  {
    :title => "Performing Arts",
    :description => "The activity of acting in, producing, directing, or writing a performance",
    :color_hex => "#0b61a4",
    :icon_class => "fa-film"
  },
  {
    :title => "Policy & Law",
    :description => "Things having to do with the governance or procedures of a society or group",
    :color_hex => "#ffcd00",
    :icon_class => "fa-gavel"
  },
  {
    :title => "Culture",
    :description => "The belief, customs, arts, and language of a particular society or group",
    :color_hex => "#53df00",
    :icon_class => "fa-globe"
  },
  {
    :title => "Economics",
    :description => "Things having to do with the production, consumption, and transfer of goods and services",
    :color_hex => "#ff3500",
    :icon_class => "fa-money"
  },
  {
    :title => "Business",
    :description => "The strategies and principles surrounding the engagement of people in commerce",
    :color_hex => "#ff2200",
    :icon_class => "fa-line-chart"
  },
  {
    :title => "Marketing",
    :description => "Any form of marketing, including digital marketing, product marketing, lead generation, and branding",
    :color_hex => "#db008e",
    :icon_class => "fa-bullhorn"
  },
  {
    :title => "Public Speaking",
    :description => "Any form of presentation skills including speeches, presentations, and demonstrations",
    :color_hex => "#05a4c2",
    :icon_class => "fa-microphone"
  },
  {
    :title => "Management",
    :description => "Any work that involves managing projects, teams, or individuals",
    :color_hex => "#c40000",
    :icon_class => "fa-briefcase"
  }
]

categories.each do |c|
  Category.find_or_create_by(c)
end
