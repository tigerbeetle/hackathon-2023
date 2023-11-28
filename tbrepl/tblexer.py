from pygments.lexer import RegexLexer, words
from pygments.token import Name


class TBLexer(RegexLexer):

    tokens = {
        'root': [
            (words(('create_accounts',
                    'lookup_accounts',
                    'create_transfers',
                    'lookup_transfers',
                    'ledger'), suffix=r'\b'), Name.Builtin),
            (r'\w+', Name),
        ],
    }
