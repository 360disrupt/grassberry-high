exports.forwardMessage = (receiver, payLoad)->
  console.log receiver, payLoad
  # switch receiver
  #   when 'cashier'
  #     console.log 'payLoad', payLoad
  #     if payLoad['commands']?
  #       for command in payLoad['commands']
  #         switch command
  #           when 'moneyBack'
  #             console.log 'moneyBack'
  #             coinAcceptorService.moneyBack()
  #           else
  #             return null
  #   else
  #     return null
