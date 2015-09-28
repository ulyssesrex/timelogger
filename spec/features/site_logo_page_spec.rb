require 'rails_helper'

describe "Site Logo Page" do
  describe "Visit site logo page" do
    before(:each) { visit(root_path) }
    
    it "has a nav bar with login button" do
      expect(find('#bs-example-navbar-collapse-2')).to have_content("Log in")
    end
    
    it "has a nav bar with no other options besides login" do
      expect(find('#bs-example-navbar-collapse-2')).not_to have_content("Help")
    end
    
    it "has a jumbotron image" do
      expect(page).to have_xpath("//img[contains(@src,'tree-trunk-rings.jpg')]")
    end
    
    it "has catchphrase text" do
      expect(page).to have_content("Timelogger: one, two, done.")
    end
    
    it "has a login button" do
      expect(page).to have_selector(:link_or_button, "Log in")
    end

    it "has a signup button" do
      expect(page).to have_selector(:link_or_button, "Sign up")
    end
    
    it "has an enroll organization button" do
      expect(page).to have_selector(:link_or_button, "Enroll organization")
    end
  end 
end