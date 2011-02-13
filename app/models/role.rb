class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table  => 'roles_users'
  
  def self.search( q, page)
    paginate :per_page =>2, :page => page,
                    :conditions => ['name like ?', "%#{q}%"], :order => 'name'
  end
end
