class Dog
    
    attr_reader :id
    attr_accessor :name, :breed
    def initialize(attributes)
        @id = attributes[:id]
        @name = attributes[:name]
        @breed = attributes[:breed]
        # attributes.map do |key, value|
        #     self.class.attr_accessor(key)
        #     self.send("#{key}=", value)
        # end
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (id INTEGER PRIMARY KEY)
            SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed:row[2])
    end

    def self.find_by_name(name)
        # binding.pry
        sql = "SELECT * FROM dogs WHERE name = ?"
        DB[:conn].execute(sql, name).map{|row| new_from_db(row)}.first
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def save
        # binding.pry
        if self.id
            self.update
        else
            sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(attributes)
        new_dog = self.new(attributes)
        new_dog.save
        new_dog
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        DB[:conn].execute(sql, id).map {|row| new_from_db(row)}.first
    end

    def self.find_or_create_by(name:, breed:)
        # binding.pry
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
        dog = DB[:conn].execute(sql, name,breed).map{|row| new_from_db(row)}.first
        # dog = self.find_by_name(attributes[:name])
        if dog.nil?
            self.create(name: name, breed: breed)
        else
            dog
        end
    end
end