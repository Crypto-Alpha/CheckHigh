# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddCollaborator service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      CheckHigh::Account.create(account_data)
    end

    share_board_data = DATA[:share_boards].first

    @owner_data = DATA[:accounts][0]
    @owner = CheckHigh::Account.all[0]
    @collaborator = CheckHigh::Account.all[1]
    @share_board = @owner.add_owned_share_board(share_board_data)
  end

  it 'HAPPY: should be able to add a collaborator to a share_board' do
    auth = authorization(@owner_data)

    CheckHigh::AddCollaborator.call(
      auth: auth,
      share_board: @share_board,
      collab_email: @collaborator.email
    )

    _(@collaborator.share_boards.count).must_equal 1
    _(@collaborator.share_boards.first).must_equal @share_board
  end

  it 'BAD: should not add owner as a collaborator' do
    auth = CheckHigh::AuthenticateAccount.call(
      email: @owner_data['email'],
      password: @owner_data['password']
    )

    _(proc {
      CheckHigh::AddCollaborator.call(
        auth: auth,
        share_board: @share_board,
        collab_email: @owner.email
      )
    }).must_raise CheckHigh::AddCollaborator::ForbiddenError
  end
end
