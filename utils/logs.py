import logging

def setup_logging(level=logging.INFO):
    logging.basicConfig(
        level=level,
        format='DEBUG_INFO: %(asctime)s %(levelname)s %(name)s %(message)s'
    )