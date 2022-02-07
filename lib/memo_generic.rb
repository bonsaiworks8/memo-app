# frozen_string_literal: true

class MemoGeneric
  BLANK_ERROR = 'タイトルまたは内容が空欄です。'
  SAVE_COMPLETED = 'メモの登録が完了しました。'
  SAVE_FAILURE = 'メモの登録に失敗しました。'
  DELETE_COMPLETED = 'メモの削除が完了しました。'
  DELETE_FAILURE = 'メモの削除に失敗しました。'

  def all
    raise NotImplementedError, 'allメソッドが実装されていません'
  end

  def save(_title, _body)
    raise NotImplementedError, 'saveメソッドが実装されていません'
  end

  def find(_id)
    raise NotImplementedError, 'findメソッドが実装されていません'
  end

  def update(_id, _title, _body)
    raise NotImplementedError, 'updateメソッドが実装されていません'
  end

  def destroy(_id)
    raise NotImplementedError, 'destroyメソッドが実装されていません'
  end
end
