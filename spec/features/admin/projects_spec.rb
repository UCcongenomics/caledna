# frozen_string_literal: true

require 'rails_helper'

describe 'Projects' do
  describe 'when researcher is a director' do
    before { login_director }

    describe '#GET projects index page' do
      it 'display project data and actions for projects' do
        create(:project, name: 'name1')
        visit admin_projects_path

        expect(page).to have_content('name1')
        expect(page).to have_content('Edit')
        expect(page).to have_content('Destroy')
        expect(page).to have_content('New project')
      end
    end

    describe '#GET projects show page' do
      it 'display project data and actions for projects' do
        project = create(:project, name: 'name1')
        visit admin_project_path(id: project.id)

        expect(page).to have_content('name1')
        expect(page).to have_content('Edit name1')
      end
    end

    describe '#GET projects new page' do
      it 'display project data and actions for projects' do
        visit new_admin_project_path

        expect(page).to have_button('Create Project')
      end
    end

    describe '#GET projects edit page' do
      it 'display project data and actions for projects' do
        project = create(:project, name: 'name1')
        visit edit_admin_project_path(id: project.id)

        expect(page).to have_content('name1')
        expect(page).to have_button('Update Project')
      end
    end
  end

  describe 'when researcher is a lab_manager' do
    before { login_lab_manager }

    describe '#GET projects index page' do
      it 'display project data and actions for projects' do
        create(:project, name: 'name1')
        visit admin_projects_path

        expect(page).to have_content('name1')
        expect(page).to_not have_content('Edit')
        expect(page).to_not have_content('Destroy')
        expect(page).to_not have_content('New project')
      end
    end

    describe '#GET projects show page' do
      it 'display project data and actions for projects' do
        project = create(:project, name: 'name1')
        visit admin_project_path(id: project.id)

        expect(page).to have_content('name1')
        expect(page).to_not have_content('Edit name1')
      end
    end
  end

  describe 'when researcher is a sample_processor' do
    before { login_sample_processor }

    describe '#GET projects index page' do
      it 'display project data and actions for projects' do
        create(:project, name: 'name1')
        visit admin_projects_path

        expect(page).to have_content('name1')
        expect(page).to_not have_content('Edit')
        expect(page).to_not have_content('Destroy')
        expect(page).to_not have_content('New project')
      end
    end

    describe '#GET projects show page' do
      it 'display project data and actions for projects' do
        project = create(:project, name: 'name1')
        visit admin_project_path(id: project.id)

        expect(page).to have_content('name1')
        expect(page).to_not have_content('Edit name1')
      end
    end
  end
end
