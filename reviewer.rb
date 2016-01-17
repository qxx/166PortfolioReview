# HOW TO USE:
# download a gradebook (csv) from Latte so we know who's enrolled
# put the gradebook in the same directory of this script



DROPBOX = "#{Dir.home}/Dropbox/"
FOLDERPREFIX = 'cosi166b_'
CURRENTDIR = Dir.pwd

def get_enrolled
  filename = %x[find . -name 'Grades*.csv']
  if filename.class!=String || filename==""
    puts "Is there a grade book in this directory?"
    exit
  end
  %x[mv *.csv Grades.csv]
  filename = CURRENTDIR + "/Grades.csv"
  enrolled = Hash.new
  f = open(filename)
  f.each_line do |line|
    if line.include? "@brandeis.edu"
      cells = line.chomp.split(",")
      name = cells[1].split('"')[1]
      uid = cells[2].split("@").first
      enrolled[uid] = name
    end
  end
  return enrolled
end

def get_dropbox
  uids=[]
  dropboxlist = %x[ls #{DROPBOX} | grep 166b_]
  dropboxlist.each_line do |line|
    uids.push line.chomp.split("_").last
  end
  uids
end

def check_hardway(foldername)
  dir = DROPBOX+foldername+"/hardway"
  filecount = Dir[File.join(dir, '**', '*')].count{|file| File.file?(file)}
  exercises = Dir[File.join(dir, '**', 'ex*.rb')]
  lastexercise = "-"
  if exercises.length > 0
    numbers = exercises.map{|exercise| exercise.split("/").last[/\d+/].to_i}
    lastexercise = numbers.sort.last.to_s
  end
  filecount = filecount > 0 ? filecount.to_s : "-"
  return filecount, lastexercise
end

def report_hardway(names, outfile)
  output = open(outfile,"w")
  output.puts("id files last_ex")
  output.puts("-"*40)
  names.each do |name|
    realname = @enrolled_hash[name] || ""
    output.printf("%-10s%4s%4s  %-s\n", name, *check_hardway(FOLDERPREFIX+name), realname)
  end
end

def check_movie1(foldername)
  filecount = %x[ls #{DROPBOX+foldername}/movies-1 2>/dev/null | wc -l].strip
  linecount = %x[cat #{DROPBOX+foldername}/movies-1/movie_data.rb 2>/dev/null | wc -l].strip
  filecount = "-" if filecount == "0"
  linecount = "-" if linecount == "0"
  return filecount,linecount
end

def report_movie1(names, outfile)
  output = open(outfile, "w")
  output.puts("id files lines")
  output.puts("-"*40)
  names.each do |name|
    realname = @enrolled_hash[name] || ""
    output.printf("%-10s%3s%4s  %-s\n", name, *check_movie1(FOLDERPREFIX+name),realname)
  end
end


@enrolled_hash = get_enrolled

# Student types
enrolled = @enrolled_hash.keys
dropbox = get_dropbox
unenrolled = dropbox - enrolled
nodropbox = enrolled - dropbox

puts "Unenrolled: #{unenrolled}"
puts "No Dropbox: #{nodropbox}"

report_movie1(dropbox, "report_movies1.txt")
report_hardway(dropbox, "report_hardway.txt")





