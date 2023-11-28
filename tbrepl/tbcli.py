import sys

from prompt_toolkit import PromptSession
from prompt_toolkit.completion import WordCompleter
from prompt_toolkit.lexers import PygmentsLexer
from prompt_toolkit.styles import Style
from tblexer import TBLexer
import tbclientwrapper
from pygments import highlight, lexers, formatters

tb_completer = WordCompleter([
                'create_accounts',
                'create_transfers',
                'help',
                'lookup_accounts',
                'lookup_transfers',
                'amount=',
                'id=',
                'code=',
                'credit_account_id=',
                'debit_account_id=',
                'ledger=',
                ], ignore_case=True)

style = Style.from_dict({
    'completion-menu.completion': 'bg:#008888 #ffffff',
    'completion-menu.completion.current': 'bg:#00aaaa #000000',
    'scrollbar.background': 'bg:#88aaaa',
    'scrollbar.button': 'bg:#222222',
})


def main(tbpath):
    session = PromptSession(
        lexer=PygmentsLexer(TBLexer), completer=tb_completer, style=style)

    while True:
        try:
            text = session.prompt('TigerBeetle Client > ')
        except KeyboardInterrupt:
            continue
        except EOFError:
            break

        try:
            message = tbclientwrapper.execute(tbpath, text)
        except Exception as e:
            print(repr(e))
        else:
            colorful_output = highlight(message, lexers.JsonLexer(), formatters.TerminalFormatter())
            print(colorful_output)

    print('GoodBye!')


if __name__ == '__main__':
    main(sys.argv[1])
