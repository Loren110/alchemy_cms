# encoding: UTF-8

require 'spec_helper'

describe Page do
	
	before(:each) do
		#@rootpage = Factory(:page, :page_layout => "rootpage", :parent_id => nil)
		#@language = @rootpage.language
		#@language_root = Factory(:page, :parent_id => @rootpage.id, :language => @language)
		@rootpage = Page.rootpage
		@language = @rootpage.language
		@language_root = Factory(:page, :parent_id => @rootpage.id, :language => @language)
	end
	
	it "should contain one rootpage" do
		Page.rootpage.should be_instance_of(Page)
	end
	
	context "finding elements" do
	
		before(:each) do
		  @page = Factory(:public_page)
			@non_public_elements = [
				Factory(:element, :public => false, :page => @page),
				Factory(:element, :public => false, :page => @page)
			]
		end
		
	  it "should return the collection of elements if passed an array into options[:collection]" do
			options = {:collection => @page.elements}
	    @page.find_elements(options).all.should == @page.elements.all
	  end
		
		context "with show_non_public argument TRUE" do

			it "should return all elements from empty options" do
			   @page.find_elements({}, true).all.should == @page.elements.all
			end

			it "should only return the elements passed as options[:only]" do
			  @page.find_elements({:only => ['article']}, true).all.should == @page.elements.named('article').all
			end

			it "should not return the elements passed as options[:except]" do
			  @page.find_elements({:except => ['article']}, true).all.should == @page.elements - @page.elements.named('article').all
			end

		  it "should return elements offsetted" do
			  @page.find_elements({:offset => 2}, true).all.should == @page.elements.offset(2)
		  end

		  it "should return elements limitted in count" do
			  @page.find_elements({:count => 1}, true).all.should == @page.elements.limit(1)
		  end

		end
		
		context "with show_non_public argument FALSE" do

			it "should return all elements from empty arguments" do
			   @page.find_elements().all.should == @page.elements.published.all
			end

			it "should only return the public elements passed as options[:only]" do
			  @page.find_elements(:only => ['article']).all.should == @page.elements.published.named('article').all
			end

			it "should return all public elements except the ones passed as options[:except]" do
			  @page.find_elements(:except => ['article']).all.should == @page.elements.published.all - @page.elements.published.named('article').all
			end

		  it "should return elements offsetted" do
			  @page.find_elements({:offset => 2}).all.should == @page.elements.published.offset(2)
		  end

		  it "should return elements limitted in count" do
			  @page.find_elements({:count => 1}).all.should == @page.elements.published.limit(1)
		  end

		end
	
	end
	
	context "create" do
		it "the rootpage with page_layout rootpage does not need a parent_id" do
			@rootpage.rootpage?.should be_true
		end
		
		it "all pages except the rootpage must have a parent_id" do
			page = Factory.build(:page, :page_layout => "anypage", :parent_id => nil, :language => @language)
			page.valid?
			page.errors.messages.should have_key(:parent_id)
		end
		
		it "must not be created if the page_layout is set to 'rootpage' and a page already exists with this page_layout and parent_id = nil" do
		  page = Factory.build(:page, :name => "anypage", :page_layout => "rootpage", :parent_id => @language_root.id, :language => @language)
			page.valid?
			page.errors.messages.should have_key(:page_layout)
		end
		
		it "should get a webfriendly urlname on create" do
			page = Factory(:page, :name => 'klingon$&stößel ', :language => @language, :parent_id => @language_root.id)
			page.urlname.should == 'klingon-stoessel'
		end

	  it "should generate a three letter urlname from two letter name" do
	    page = Factory(:page, :name => 'Au', :language => @language, :parent_id => @language_root.id)
	    page.urlname.should == '-au'
	  end

	  it "should generate a three letter urlname from two letter name with umlaut" do
	    page = Factory(:page, :name => 'Aü', :language => @language, :parent_id => @language_root.id)
	    page.urlname.should == 'aue'
	  end

	  it "should generate a three letter urlname from one letter name" do
	    page = Factory(:page, :name => 'A', :language => @language, :parent_id => @language_root.id)
	    page.urlname.should == '--a'
	  end
	end
	
	context "with children" do
		before(:each) do
			@first_child = Factory(:page, :name => "First child", :language => @language, :public => false, :parent_id => @language_root.id)
			@first_child.move_to_child_of(@language_root)
			
			@first_public_child = Factory(:page, :name => "First public child", :language => @language, :parent_id => @language_root.id, :public => true)
			@first_public_child.move_to_child_of(@language_root)
		end
		
		it "should return a page object (or nil if no public child exists) for first_public_child" do
			if @language_root.children.any?
				@language_root.first_public_child.should == @first_public_child
			else
				@language_root.first_public_child.should == nil
			end
		end
	end
	
end